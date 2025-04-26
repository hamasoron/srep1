# アウトプットの定義
## VPC
output "vpc_id" {
  description = "VPCのID"
  value       = aws_vpc.terra_vpc.id
}

output "subnet_ids" {
  description = "サブネットのID"
  value       = { for k, v in aws_subnet.terra_subnet : k => v.id }
}

output "public_subnet_ids" {
  description = "パブリックサブネットのID"
  value       = { for k, v in aws_subnet.terra_subnet : substr(k, 7, 2) => v.id if substr(k, 0, 6) == "public" }
}

output "private_subnet_ids" {
  description = "プライベートサブネットのID"
  value       = { for k, v in aws_subnet.terra_subnet : substr(k, 8, 2) => v.id if substr(k, 0, 7) == "private" }
}

output "protected_subnet_ids" {
  description = "保護されたサブネットのID"
  value       = { for k, v in aws_subnet.terra_subnet : substr(k, 10, 2) => v.id if substr(k, 0, 9) == "protected" }
}

output "internet_gateway_id" {
  description = "インターネットゲートウェイのID"
  value = aws_internet_gateway.terra_internet_gateway.id
}

output "nat_gateway_eip_id" {
  description = "NATゲートウェイ用のEIPのID（条件付き）"
  value = var.create_protected_ngw_associations ? aws_eip.terra_eip_ngw[0].id : null
}

output "nat_gateway_id" {
  description = "NATゲートウェイのID（条件付き）"
  value = var.create_protected_ngw_associations ? aws_nat_gateway.terra_nat_gateway[0].id : null
}

output "route_table_ids" {
  description = "ルートテーブルのID"
  value = concat(
    [for rt in aws_route_table.terra_route_table_public : rt.id],
    var.create_protected_ngw_associations ? [for rt in aws_route_table.terra_route_table_protected : rt.id] : [],
    [for rt in aws_route_table.terra_route_table_private : rt.id]
  )
}

output "route_table_association_ids" {
  description = "サブネットとルートテーブルの関連付けのID"
  value = [for assoc in aws_route_table_association.terra_route_table_association : assoc.id]
}

output "s3_vpc_endpoint_id" {
  description = "S3のVPCエンドポイントのID"
  value = aws_vpc_endpoint.terra_s3_endpoint.id
}

output "dynamodb_vpc_endpoint_id" {
  description = "DynamoDBのVPCエンドポイントのID"
  value = aws_vpc_endpoint.terra_dynamodb_endpoint.id
}

output "protected_subnet_resource_ids" {
  description = "リソースIDとしてのProtectedサブネットID一覧（依存関係解決用）"
  value       = [for k, v in aws_subnet.terra_subnet : v.id if substr(k, 0, 9) == "protected"]
}