# アウトプットの定義
## VPC
output "create_protected_ngw_associations" {
  description = "プロテクテッドサブネット及びNATゲートウェイ関連の作成有無（ECSモジュール等で使用）"
  value       = var.create_protected_ngw_associations
}

output "vpc_id" {
  description = "VPCのID（SGやALBモジュールなどでVPCを指定する際に使用）"
  value       = aws_vpc.terra_vpc.id
}

output "subnet_ids" {
  description = "サブネットのID（AZやNAT構成に応じて動的に変化する全てのサブネットのIDを必ず取得。ECSモジュール等で使用）"
  value       = { for k, v in aws_subnet.terra_subnet : k => v.id }
}

output "public_subnet_ids" {
  description = "パブリックサブネットのID（AZやNAT構成に応じて動的に変化するパブリックサブネットのIDを必ず取得。ALBモジュール等で使用）"
  value       = { for k, v in aws_subnet.terra_subnet : substr(k, 7, 2) => v.id if substr(k, 0, 6) == "public" }
}

output "private_subnet_ids" {
  description = "プライベートサブネットのID（AZやNAT構成に応じて動的に変化するプライベートサブネットのIDを必ず取得。RDSモジュール等で使用）"
  value       = { for k, v in aws_subnet.terra_subnet : substr(k, 8, 2) => v.id if substr(k, 0, 7) == "private" }
}

output "protected_subnet_ids" {
  description = "プロテクテッドサブネットのID（AZやNAT構成に応じて動的に変化するプロテクテッドサブネットのIDを必ず取得）"
  value       = { for k, v in aws_subnet.terra_subnet : substr(k, 10, 2) => v.id if substr(k, 0, 9) == "protected" }
}

output "route_table_ids" {
  description = "ルートテーブルのID（AZやNAT構成に応じて動的に変化する全てのルートテーブルのIDを必ず取得）"
  value = concat(
    [for rt in aws_route_table.terra_route_table_public : rt.id],
    var.create_protected_ngw_associations ? [for rt in aws_route_table.terra_route_table_protected : rt.id] : [],
    [for rt in aws_route_table.terra_route_table_private : rt.id]
  )
}