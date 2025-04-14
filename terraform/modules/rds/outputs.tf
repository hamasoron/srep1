output "cluster_id" {
  description = "Aurora MySQLクラスターのID"
  value       = aws_rds_cluster.aurora_mysql_cluster.id
}

output "cluster_endpoint" {
  description = "ライターエンドポイント"
  value       = aws_rds_cluster.aurora_mysql_cluster.endpoint
}

output "cluster_reader_endpoint" {
  description = "リーダーエンドポイント"
  value       = aws_rds_cluster.aurora_mysql_cluster.reader_endpoint
}

output "cluster_port" {
  description = "クラスターのポート番号"
  value       = aws_rds_cluster.aurora_mysql_cluster.port
}

output "instance_ids" {
  description = "Aurora MySQLインスタンスのID"
  value       = aws_rds_cluster_instance.aurora_instance[*].id
}

output "db_name" {
  description = "データベース名"
  value       = aws_rds_cluster.aurora_mysql_cluster.database_name
} 