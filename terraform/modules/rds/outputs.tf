# アウトプットの定義
## RDS
output "cluster_id" {
  description = "AuroraクラスターのID"
  value       = aws_rds_cluster.terra_rds_cluster.id
}

output "cluster_endpoint" {
  description = "ライターエンドポイント（ECSモジュールの環境変数の設定等で使用）"
  value       = aws_rds_cluster.terra_rds_cluster.endpoint
}

output "cluster_reader_endpoint" {
  description = "リーダーエンドポイント（ECSモジュールの環境変数の設定等で使用）"
  value       = aws_rds_cluster.terra_rds_cluster.reader_endpoint
}

output "cluster_port" {
  description = "Aurora クラスターのポート番号（ECSモジュールの環境変数の設定等で使用）"
  value       = aws_rds_cluster.terra_rds_cluster.port
}

output "cluster_database_name" {
  description = "Aurora クラスターのデフォルトデータベース名（ECSモジュールの環境変数の設定等で使用）"
  value       = aws_rds_cluster.terra_rds_cluster.database_name
}