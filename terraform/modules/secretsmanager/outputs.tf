# アウトプットの定義
## Secrets Manager
output "secretsmanager_rds_master_secret_arn" {
  description = "RDS master user secretのARN（ECSモジュールの環境変数の設定等で使用）"
  value       = aws_secretsmanager_secret.terra_secretsmanager_secret_master.arn
}

output "secretsmanager_master_credentials_json" {
  description = "マスターユーザーの認証情報（RDSモジュールのmaster_usernameとmaster_passwordに使用）"
  value       = aws_secretsmanager_secret_version.terra_secretsmanager_secret_version_rds_master.secret_string
  sensitive   = true
}

output "secretsmanager_rds_app_secret_arn" {
  description = "RDS app user secretのARN（ECSモジュールの環境変数の設定等で使用）"
  value       = aws_secretsmanager_secret.terra_secretsmanager_secret_app.arn
}