# アウトプットの定義
## VPCのIDを出力
output "vpc_id" {
  value = module.vpc.vpc_id
}

## サブネットのIDを出力
output "subnet_ids" {
  value = module.vpc.subnet_ids
}

## インターネットゲートウェイのIDを出力
output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

## NATゲートウェイ用のEIPのIDを出力（条件付き）
output "nat_gateway_eip_id" {
  description = "NATゲートウェイ用のElastic IPのID"
  value       = module.vpc.nat_gateway_eip_id
}

## NATゲートウェイのIDを出力（条件付き）
output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

## ルートテーブルのIDを出力
output "route_table_ids" {
  value = module.vpc.route_table_ids
}

## サブネットとルートテーブルの関連付けのIDを出力
output "route_table_association_ids" {
  value = module.vpc.route_table_association_ids
}

## VPCエンドポイントのIDを出力
output "s3_vpc_endpoint_id" {
  value = module.vpc.s3_vpc_endpoint_id
}

output "dynamodb_vpc_endpoint_id" {
  value = module.vpc.dynamodb_vpc_endpoint_id
}

## セキュリティグループのIDを出力
output "security_group_ids" {
  value = module.sg.security_group_ids
}
