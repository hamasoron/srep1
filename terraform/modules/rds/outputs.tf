# アウトプットの定義
## RDS
output "rds_cluster_id" {
  description = "AuroraクラスターのID"
  value       = aws_rds_cluster.terra_rds_cluster.id
}

output "rds_cluster_writer_endpoint" {
  description = "Auroraクラスターのエンドポイント（Lambdaモジュール、ECSモジュールの環境変数の設定等で使用）"
  value       = aws_rds_cluster.terra_rds_cluster.endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "Auroraクラスターのリーダーエンドポイント（ECSモジュールの環境変数の設定等で使用）"
  value       = aws_rds_cluster.terra_rds_cluster.reader_endpoint
}

output "rds_cluster_port" {
  description = "Aurora クラスターのポート番号（Lambdaモジュール、ECSモジュールの環境変数の設定等で使用）"
  value       = aws_rds_cluster.terra_rds_cluster.port
}

output "rds_cluster_database_name" {
  description = "Aurora クラスターのデフォルトデータベース名（ECSモジュールの環境変数の設定等で使用）"
  value       = aws_rds_cluster.terra_rds_cluster.database_name
}