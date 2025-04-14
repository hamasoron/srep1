# リソースの定義
## VPCの作成
resource "aws_vpc" "terra_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.system_name}-${var.environment_name}-vpc"
  }
}

## サブネットの作成
resource "aws_subnet" "terra_subnet" {
  for_each   = { for subnet in var.subnet_list : "${subnet.type}-${subnet.name}" => subnet if var.create_protected_ngw_associations || subnet.type != "protected" }
  vpc_id     = aws_vpc.terra_vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = lookup({
    "1a" = "ap-northeast-1a",
    "1c" = "ap-northeast-1c",
    "1d" = "ap-northeast-1d"
  }, substr(each.value.name, -2, 2), "ap-northeast-1a")
  tags = {
    Name = "${var.system_name}-${var.environment_name}-${each.value.type}-subnet-${each.value.name}"
  }
}

## インターネットゲートウェイの作成
resource "aws_internet_gateway" "terra_internet_gateway" {
  vpc_id = aws_vpc.terra_vpc.id
  tags = {
    Name = "${var.system_name}-${var.environment_name}-igw"
  }
}

## NATゲートウェイ用のEIPの作成（条件付き）
resource "aws_eip" "terra_eip_ngw" {
  count  = var.create_protected_ngw_associations ? 1 : 0
  domain = "vpc"
  tags = {
    Name = "${var.system_name}-${var.environment_name}-ngw-1a"
  }
  depends_on = [aws_internet_gateway.terra_internet_gateway]
}

## NATゲートウェイの作成（条件付き）
resource "aws_nat_gateway" "terra_nat_gateway" {
  count         = var.create_protected_ngw_associations ? 1 : 0
  allocation_id = aws_eip.terra_eip_ngw[0].id
  subnet_id     = aws_subnet.terra_subnet["public-1a"].id
  tags = {
    Name = "${var.system_name}-${var.environment_name}-ngw-1a"
  }
  depends_on = [aws_internet_gateway.terra_internet_gateway, aws_eip.terra_eip_ngw]
  
  # NATゲートウェイの関連付けが完全に完了するまで待機する設定
  lifecycle {
    create_before_destroy = true
  }
}

# NATゲートウェイの状態が完全に利用可能になるまで待機するリソース
resource "time_sleep" "wait_for_nat" {
  count = var.create_protected_ngw_associations ? 1 : 0
  depends_on = [aws_nat_gateway.terra_nat_gateway]
  create_duration = "30s"
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
  for_each = var.create_protected_ngw_associations ? { for rt in var.route_table_list : rt.name == "protected" ? rt.subnet : "" => rt if rt.name == "protected" } : {}
  vpc_id   = aws_vpc.terra_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terra_nat_gateway[0].id
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-protected-rtb-${each.key}"
  }
  depends_on = [time_sleep.wait_for_nat]
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
  for_each  = { for subnet in var.subnet_list : "${subnet.type}-${subnet.name}" => subnet if var.create_protected_ngw_associations || subnet.type != "protected" }
  subnet_id = aws_subnet.terra_subnet[each.key].id
  route_table_id = lookup(
    merge(
      { public = aws_route_table.terra_route_table_public[each.value.name].id },
      var.create_protected_ngw_associations ? { protected = aws_route_table.terra_route_table_protected[each.value.name].id } : {},
      { private = aws_route_table.terra_route_table_private[each.value.name].id }
    ),
    each.value.type
  )
}

## VPCエンドポイントの作成
resource "aws_vpc_endpoint" "terra_s3_endpoint" {
  vpc_id       = aws_vpc.terra_vpc.id
  service_name = "com.amazonaws.ap-northeast-1.s3"
  route_table_ids = flatten(concat(
    [for key, rt in aws_route_table.terra_route_table_public : rt.id],
    var.create_protected_ngw_associations ? [for key, rt in aws_route_table.terra_route_table_protected : rt.id] : []
  ))
  tags = {
    Name = "${var.system_name}-${var.environment_name}-s3-endpoint"
  }
  lifecycle {
    ignore_changes = [route_table_ids]
  }
  depends_on = [aws_route_table_association.terra_route_table_association]
}

resource "aws_vpc_endpoint" "terra_dynamodb_endpoint" {
  vpc_id       = aws_vpc.terra_vpc.id
  service_name = "com.amazonaws.ap-northeast-1.dynamodb"
  route_table_ids = flatten(concat(
    [for key, rt in aws_route_table.terra_route_table_public : rt.id],
    var.create_protected_ngw_associations ? [for key, rt in aws_route_table.terra_route_table_protected : rt.id] : []
  ))
  tags = {
    Name = "${var.system_name}-${var.environment_name}-dynamodb-endpoint"
  }
  lifecycle {
    ignore_changes = [route_table_ids]
  }
  depends_on = [aws_route_table_association.terra_route_table_association]
}