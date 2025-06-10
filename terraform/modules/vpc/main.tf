# ローカル変数の定義
## NATゲートウェイの設定
locals {
  ### available_azs：terraform.tfvarsのsubnet_listのnameの末尾2文字（つまりAZ名）を抽出して格納
  available_azs = length(distinct([for subnet in var.subnet_list : substr(subnet.name, -2, 2)]))
  ### filtered_subnet_list：create_protected_ngw_associationsがfalseの場合は、subnet_listのtypeがprotectedのものを除外して格納
  filtered_subnet_list = [
    for subnet in var.subnet_list : subnet 
    if var.create_protected_ngw_associations || subnet.type != "protected"
  ]
  ### has_protected_subnets：create_protected_ngw_associationsがtrueかつsubnet_listの中にtypeが"protected"のサブネットが1つ以上ある場合にtrue、そうでなければfalseを格納
  has_protected_subnets = var.create_protected_ngw_associations && length([for subnet in var.subnet_list : subnet if subnet.type == "protected"]) > 0
  ### enabled_nat_gateways：create_protected_ngw_associationsがtrueの場合は、nat_gateway_listの中でenabledがtrueのものを抽出して格納、そうでなければ空配列を格納
  enabled_nat_gateways = var.create_protected_ngw_associations ? [for ngw in var.nat_gateway_list : ngw if ngw.enabled] : []
  ### final_nat_count：enabled_nat_gatewaysの要素数を格納
  final_nat_count = length(local.enabled_nat_gateways)
  ### nat_gateway_subnets：enabled_nat_gatewaysの要素数分のオブジェクトを作成して格納。nameはenabled_nat_gatewaysの要素のaz、typeは"public"
  nat_gateway_subnets = [
    for ngw in local.enabled_nat_gateways : 
      { name = ngw.az, cidr_block = "", type = "public" }
  ]
}

# リソースの定義
## VPCの作成
resource "aws_vpc" "terra_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default" ##### EC2インスタンスを起動する際に物理ハードウェアを共有するか占有するか
  enable_dns_support   = true  ##### VPC内のリソースに、Route53のキャッシュDNSサーバー（x.x.x.2）が権威DNSサーバーに問い合わせて名前解決を行えるかどうか
  enable_dns_hostnames = true  ##### VPC内のリソースに、パブリックDNS名やプライベートDNS名を付与するかどうか
  tags = {
    Name = "${var.system_name}-${var.environment_name}-vpc"
  }
}

## サブネットの作成
resource "aws_subnet" "terra_subnet" {
  for_each   = { for subnet in local.filtered_subnet_list : "${subnet.type}-${subnet.name}" => subnet }
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
      ### 要件に基づいたNATゲートウェイ選択ロジック
      nat_gateway_id = (
        ### 2AZ環境の場合（local.available_azs == 2）
        local.available_azs == 2 ? (
          ### NATゲートウェイが1つの場合：全てのprotectedサブネットが1aのNATゲートウェイを経由
          local.final_nat_count == 1 ? 
            aws_nat_gateway.terra_nat_gateway[0].id :
          ### NATゲートウェイが2つの場合：各protectedサブネットが同じAZ内のNATゲートウェイを経由
          (each.key == "1a" ? [for ngw in aws_nat_gateway.terra_nat_gateway : ngw.id if can(regex("1a", ngw.tags.Name))][0] :
           each.key == "1c" ? [for ngw in aws_nat_gateway.terra_nat_gateway : ngw.id if can(regex("1c", ngw.tags.Name))][0] :
           aws_nat_gateway.terra_nat_gateway[0].id)
        ) :
        ### 3AZ環境の場合（local.available_azs == 3）
        local.available_azs == 3 ? (
          ### NATゲートウェイが1つの場合：全てのprotectedサブネットが1aのNATゲートウェイを経由
          local.final_nat_count == 1 ? 
            aws_nat_gateway.terra_nat_gateway[0].id :
          ### NATゲートウェイが2つの場合
          local.final_nat_count == 2 ? (
            each.key == "1a" ? [for ngw in aws_nat_gateway.terra_nat_gateway : ngw.id if can(regex("1a", ngw.tags.Name))][0] :
            ### 1cと1dは両方ともcのルートテーブルを使用
            (each.key == "1c" || each.key == "1d") ? [for ngw in aws_nat_gateway.terra_nat_gateway : ngw.id if can(regex("1c", ngw.tags.Name))][0] :
            aws_nat_gateway.terra_nat_gateway[0].id
          ) :
          ### NATゲートウェイが3つの場合
          local.final_nat_count == 3 ? (
            each.key == "1a" ? [for ngw in aws_nat_gateway.terra_nat_gateway : ngw.id if can(regex("1a", ngw.tags.Name))][0] :
            each.key == "1c" ? [for ngw in aws_nat_gateway.terra_nat_gateway : ngw.id if can(regex("1c", ngw.tags.Name))][0] :
            each.key == "1d" ? [for ngw in aws_nat_gateway.terra_nat_gateway : ngw.id if can(regex("1d", ngw.tags.Name))][0] :
            aws_nat_gateway.terra_nat_gateway[0].id
          ) :
          ### その他の場合（デフォルト）
          aws_nat_gateway.terra_nat_gateway[0].id
        ) :
        ### その他の場合（1AZなど）
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
  for_each  = { for subnet in local.filtered_subnet_list : "${subnet.type}-${subnet.name}" => subnet }
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