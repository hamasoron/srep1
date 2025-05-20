# アウトプットの定義
## VPC
output "vpc_create_protected_ngw_associations" {
  description = "プロテクテッドサブネット及びNATゲートウェイ関連の作成有無（ECSモジュール等で使用）"
  value       = var.create_protected_ngw_associations
}

output "vpc_id" {
  description = "VPCのID（SGやALBモジュール等でVPCを指定する際に使用）"
  value       = aws_vpc.terra_vpc.id
}

output "vpc_public_subnet_ids" {
  description = "パブリックサブネットのID（AZやNAT構成に応じて動的に変化するパブリックサブネットのIDを必ず取得。ALBモジュール等で使用）"
  value       = { for k, v in aws_subnet.terra_subnet : substr(k, 7, 2) => v.id if substr(k, 0, 6) == "public" }
}

output "vpc_private_subnet_ids" {
  description = "プライベートサブネットのID（AZやNAT構成に応じて動的に変化するプライベートサブネットのIDを必ず取得。ECSモジュール等で使用）"
  value       = { for k, v in aws_subnet.terra_subnet : substr(k, 8, 2) => v.id if substr(k, 0, 7) == "private" }
}

output "vpc_protected_subnet_ids" {
  description = "プロテクテッドサブネットのID（AZやNAT構成に応じて動的に変化するプロテクテッドサブネットのIDを必ず取得。ECSモジュール等で使用）"
  value       = { for k, v in aws_subnet.terra_subnet : substr(k, 10, 2) => v.id if substr(k, 0, 9) == "protected" }
}

output "vpc_route_table_ids" {
  description = "ルートテーブルのID"
  value = concat(
    [for rt in aws_route_table.terra_route_table_public : rt.id],
    var.create_protected_ngw_associations ? [for rt in aws_route_table.terra_route_table_protected : rt.id] : [],
    [for rt in aws_route_table.terra_route_table_private : rt.id]
  )
}