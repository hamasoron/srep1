# ローカル変数の定義
## NATゲートウェイの数を計算するロジック
locals {
  ### subnet_listからAZの数をチェック
  available_azs = length(distinct([for subnet in var.subnet_list : substr(subnet.name, -2, 2)]))
  ### protected subnetが存在するかチェック
  has_protected_subnets = length([for subnet in var.subnet_list : subnet if subnet.type == "protected"]) > 0
  ### NATゲートウェイ設定の優先順位決定
  # 1. nat_gateway_list (新しいlist型設定)
  # 2. nat_gateway_count (従来の変数)
  # 3. 自動計算 (後方互換性)
  ### nat_gateway_listから有効なNATゲートウェイを抽出
  enabled_nat_gateways = [for ngw in var.nat_gateway_list : ngw if ngw.enabled]
  ### 後方互換性のためのデフォルトマッピングテーブル
  default_nat_count_map = {
    # dev環境（2az:0個か1個、3az:0個か1個）
    "dev-2az-true"  = 1
    "dev-3az-true"  = 1
    "dev-2az-false" = 0
    "dev-3az-false" = 0
    # stg環境（2az:2個、3az:2個か3個）
    "stg-2az-true"  = 2
    "stg-3az-true"  = var.use_all_azs_for_nat ? 3 : 2
    "stg-2az-false" = 0
    "stg-3az-false" = 0
    # prod環境（2az:2個、3az:2個か3個）
    "prod-2az-true"  = 2
    "prod-3az-true"  = var.use_all_azs_for_nat ? 3 : 2
    "prod-2az-false" = 0
    "prod-3az-false" = 0
  }
  ### キーを生成してマップから値を取得
  lookup_key = "${var.environment_name}-${local.available_azs}az-${local.has_protected_subnets}"
  ### 後方互換性のための従来ロジック
  legacy_calculated_nat_count = var.enable_auto_nat_calculation ? lookup(local.default_nat_count_map, local.lookup_key, 0) : 0
  ### 最終的なNATゲートウェイ数の決定（優先順位順）
  final_nat_count = (
    # 1. nat_gateway_listでの明示的指定
    length(local.enabled_nat_gateways) > 0 ? length(local.enabled_nat_gateways) :
    # 2. 従来のnat_gateway_count変数
    var.nat_gateway_count != null ? var.nat_gateway_count :
    # 3. 従来の自動計算（後方互換性）
    local.legacy_calculated_nat_count
  ) 
  ### NATゲートウェイ配置用のpublic subnet（既存ロジック）
  public_subnets = [for subnet in var.subnet_list : subnet if subnet.type == "public"]
  ### NATゲートウェイを配置するサブネット名のリスト
  nat_gateway_subnets = length(local.enabled_nat_gateways) > 0 ? [
    # nat_gateway_listが指定されている場合は、enabledなAZのpublic subnetを使用
    for ngw in local.enabled_nat_gateways : 
      { name = ngw.az, cidr_block = "", type = "public" }
  ] : slice(local.public_subnets, 0, min(local.final_nat_count, length(local.public_subnets)))
  ### 設定ソース情報
  config_source = (
    length(local.enabled_nat_gateways) > 0 ? "nat_gateway_list" :
    var.nat_gateway_count != null ? "legacy_variable" :
    "legacy_auto"
  )
}

# リソースの定義
## VPCの作成
resource "aws_vpc" "terra_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.system_name}-${var.environment_name}-vpc"
  }
}

## サブネットの作成
resource "aws_subnet" "terra_subnet" {
  for_each   = { for subnet in var.subnet_list : "${subnet.type}-${subnet.name}" => subnet if local.has_protected_subnets || subnet.type != "protected" }
  availability_zone = lookup({
    "1a" = "ap-northeast-1a",
    "1c" = "ap-northeast-1c",
    "1d" = "ap-northeast-1d"
  }, substr(each.value.name, -2, 2), "ap-northeast-1a")
  cidr_block              = each.value.cidr_block
  vpc_id                  = aws_vpc.terra_vpc.id
  map_public_ip_on_launch = each.value.type == "public" ? var.map_public_ip_on_launch : false
  tags = {
    Name = "${var.system_name}-${var.environment_name}-${each.value.type}-subnet-${each.value.name}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

## インターネットゲートウェイの作成
resource "aws_internet_gateway" "terra_internet_gateway" {
  vpc_id = aws_vpc.terra_vpc.id
  tags = {
    Name = "${var.system_name}-${var.environment_name}-igw"
  }
}

## NATゲートウェイ用のEIPの作成
resource "aws_eip" "terra_eip_ngw" {
  count  = local.final_nat_count
  domain = "vpc"
  tags = {
    Name = "${var.system_name}-${var.environment_name}-ngw-${local.nat_gateway_subnets[count.index].name}"
  }
  depends_on = [aws_internet_gateway.terra_internet_gateway]
}

## NATゲートウェイの作成
resource "aws_nat_gateway" "terra_nat_gateway" {
  count         = local.final_nat_count
  allocation_id = aws_eip.terra_eip_ngw[count.index].id
  subnet_id     = aws_subnet.terra_subnet["public-${local.nat_gateway_subnets[count.index].name}"].id
  tags = {
    Name = "${var.system_name}-${var.environment_name}-ngw-${local.nat_gateway_subnets[count.index].name}"
  }
  depends_on = [aws_internet_gateway.terra_internet_gateway, aws_eip.terra_eip_ngw]
}

## ルートテーブルの作成
resource "aws_route_table" "terra_route_table_public" {
  for_each = { for rt in var.route_table_list : rt.name == "public" ? rt.subnet : "" => rt if rt.name == "public" }
  vpc_id   = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_internet_gateway.id
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-public-rtb-${each.key}"
  }
}

resource "aws_route_table" "terra_route_table_protected" {
  for_each = local.has_protected_subnets ? { for rt in var.route_table_list : rt.name == "protected" ? rt.subnet : "" => rt if rt.name == "protected" } : {}
  vpc_id   = aws_vpc.terra_vpc.id
  
  dynamic "route" {
    for_each = local.final_nat_count > 0 ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      # 改善されたNATゲートウェイ選択ロジック
      nat_gateway_id = local.final_nat_count == 1 ? aws_nat_gateway.terra_nat_gateway[0].id : (
        # 完全一致する場合はそのNAT gatewayを使用
        length([for ngw in aws_nat_gateway.terra_nat_gateway : ngw if can(regex(each.key, ngw.tags.Name))]) > 0 ?
        [for ngw in aws_nat_gateway.terra_nat_gateway : ngw.id if can(regex(each.key, ngw.tags.Name))][0] :
        # フォールバック: 3AZ環境でNAT gateway数が少ない場合の賢い選択
        # 1d → 最後のNAT gateway (通常1c), 1c → 最後から2番目または最後, 1a → 最初
        each.key == "1d" ? aws_nat_gateway.terra_nat_gateway[local.final_nat_count - 1].id :
        each.key == "1c" ? aws_nat_gateway.terra_nat_gateway[min(1, local.final_nat_count - 1)].id :
        aws_nat_gateway.terra_nat_gateway[0].id
      )
    }
  }
  
  tags = {
    Name = "${var.system_name}-${var.environment_name}-protected-rtb-${each.key}"
  }
}

resource "aws_route_table" "terra_route_table_private" {
  for_each = { for rt in var.route_table_list : rt.name == "private" ? rt.subnet : "" => rt if rt.name == "private" }
  vpc_id   = aws_vpc.terra_vpc.id
  tags = {
    Name = "${var.system_name}-${var.environment_name}-private-rtb-${each.key}"
  }
}

## サブネットとルートテーブルの関連付け
resource "aws_route_table_association" "terra_route_table_association" {
  for_each  = { for subnet in var.subnet_list : "${subnet.type}-${subnet.name}" => subnet if local.has_protected_subnets || subnet.type != "protected" }
  subnet_id = aws_subnet.terra_subnet[each.key].id
  route_table_id = lookup(
    merge(
      { public = aws_route_table.terra_route_table_public[each.value.name].id },
      local.has_protected_subnets ? { protected = aws_route_table.terra_route_table_protected[each.value.name].id } : {},
      { private = aws_route_table.terra_route_table_private[each.value.name].id }
    ),
    each.value.type
  )
}

## VPCエンドポイントの作成
resource "aws_vpc_endpoint" "terra_vpc_endpoint_s3" {
  vpc_id       = aws_vpc.terra_vpc.id
  service_name = "com.amazonaws.ap-northeast-1.s3"
  route_table_ids = flatten(concat(
    [for key, rt in aws_route_table.terra_route_table_public : rt.id],
    local.has_protected_subnets ? [for key, rt in aws_route_table.terra_route_table_protected : rt.id] : []
  ))
  tags = {
    Name = "${var.system_name}-${var.environment_name}-s3-endpoint"
  }
  lifecycle {
    ignore_changes = [route_table_ids]
  }
  depends_on = [aws_route_table_association.terra_route_table_association]
}

resource "aws_vpc_endpoint" "terra_vpc_endpoint_dynamodb" {
  vpc_id       = aws_vpc.terra_vpc.id
  service_name = "com.amazonaws.ap-northeast-1.dynamodb"
  route_table_ids = flatten(concat(
    [for key, rt in aws_route_table.terra_route_table_public : rt.id],
    local.has_protected_subnets ? [for key, rt in aws_route_table.terra_route_table_protected : rt.id] : []
  ))
  tags = {
    Name = "${var.system_name}-${var.environment_name}-dynamodb-endpoint"
  }
  lifecycle {
    ignore_changes = [route_table_ids]
  }
  depends_on = [aws_route_table_association.terra_route_table_association]
}

## サブネットとVPCエンドポイントの関連付け
resource "aws_vpc_endpoint_route_table_association" "terra_vpc_endpoint_protected_associations_s3" {
  for_each = local.has_protected_subnets ? { for rt in var.route_table_list : rt.name == "protected" ? rt.subnet : "" => rt if rt.name == "protected" } : {}
  vpc_endpoint_id = aws_vpc_endpoint.terra_vpc_endpoint_s3.id
  route_table_id  = aws_route_table.terra_route_table_protected[each.key].id
}

resource "aws_vpc_endpoint_route_table_association" "terra_vpc_endpoint_protected_associations_dynamodb" {
  for_each = local.has_protected_subnets ? { for rt in var.route_table_list : rt.name == "protected" ? rt.subnet : "" => rt if rt.name == "protected" } : {}
  vpc_endpoint_id = aws_vpc_endpoint.terra_vpc_endpoint_dynamodb.id
  route_table_id  = aws_route_table.terra_route_table_protected[each.key].id
}