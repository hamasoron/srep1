# アウトプットの定義
## RDS
output "cluster_id" {
  description = "AuroraクラスターのID"
  value       = aws_rds_cluster.terra_rds_cluster.id
}

output "cluster_endpoint" {
  description = "ライターエンドポイント"
  value       = aws_rds_cluster.terra_rds_cluster.endpoint
}

output "cluster_reader_endpoint" {
  description = "リーダーエンドポイント"
  value       = aws_rds_cluster.terra_rds_cluster.reader_endpoint
}

output "cluster_port" {
  description = "クラスターのポート番号"
  value       = aws_rds_cluster.terra_rds_cluster.port
}

output "instance_ids" {
  description = "AuroraインスタンスのID"
  value       = aws_rds_cluster_instance.terra_rds_cluster_instance[*].id
}

output "db_name" {
  description = "データベース名"
  value       = aws_rds_cluster.terra_rds_cluster.database_name
} 