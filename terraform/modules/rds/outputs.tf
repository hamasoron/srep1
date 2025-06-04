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

output "rds_cluster_identifier" {
  description = "Aurora クラスターの識別子（Lambdaモジュールのmasterユーザーのローテーションでのみ使用。appユーザーのローテーションでは使用しない）"
  value       = aws_rds_cluster.terra_rds_cluster.cluster_identifier
}

output "rds_cluster_instance_details" {
  description = "Auroraインスタンスの詳細情報（ID、AZ、役割）"
  value = [
    for i, instance in aws_rds_cluster_instance.terra_rds_cluster_instance : {
      id   = instance.id
      az   = instance.availability_zone
      role = i == 0 ? "writer" : "reader"
      promotion_tier = instance.promotion_tier
    }
  ]
}