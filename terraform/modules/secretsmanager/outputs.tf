# アウトプットの定義
## Secrets Manager
output "secretsmanager_secret_arns" {
  description = "マップ形式のシークレットのARN（Lambdaモジュールのシークレット関連で使用）"
  value       = { for k, v in aws_secretsmanager_secret.terra_secretsmanager_secret : k => v.arn }
}

output "secretsmanager_master_credentials_json" {
  description = "マスターユーザーの認証情報（RDSモジュールのmaster_usernameとmaster_passwordに使用）"
  value       = aws_secretsmanager_secret_version.terra_secretsmanager_secret_version[var.secrets[0].name].secret_string
  sensitive   = true
}