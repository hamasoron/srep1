# アウトプットの定義
## VPCのIDを出力
output "vpc_id" {
  value = aws_vpc.terra_vpc.id
}

## サブネットのIDを出力
output "subnet_ids" {
  value = { for key, subnet in aws_subnet.terra_subnet : key => subnet.id }
}

## パブリックサブネットのIDを出力
output "public_subnet_ids" {
  value = { for key, subnet in aws_subnet.terra_subnet : 
    substr(key, -2, 2) => subnet.id 
    if substr(key, 0, 7) == "public-"
  }
}

## インターネットゲートウェイのIDを出力
output "internet_gateway_id" {
  value = aws_internet_gateway.terra_internet_gateway.id
}

## NATゲートウェイ用のEIPのIDを出力（条件付き）
output "nat_gateway_eip_id" {
  value = var.create_protected_ngw_associations ? aws_eip.terra_eip_ngw[0].id : null
}

## NATゲートウェイのIDを出力（条件付き）
output "nat_gateway_id" {
  value = var.create_protected_ngw_associations ? aws_nat_gateway.terra_nat_gateway[0].id : null
}

## ルートテーブルのIDを出力
output "route_table_ids" {
  value = concat(
    [for rt in aws_route_table.terra_route_table_public : rt.id],
    var.create_protected_ngw_associations ? [for rt in aws_route_table.terra_route_table_protected : rt.id] : [],
    [for rt in aws_route_table.terra_route_table_private : rt.id]
  )
}

## サブネットとルートテーブルの関連付けのIDを出力
output "route_table_association_ids" {
  value = [for assoc in aws_route_table_association.terra_route_table_association : assoc.id]
}

## VPCエンドポイントのIDを出力
output "s3_vpc_endpoint_id" {
  value = aws_vpc_endpoint.terra_s3_endpoint.id
}

output "dynamodb_vpc_endpoint_id" {
  value = aws_vpc_endpoint.terra_dynamodb_endpoint.id
}