# アウトプットの定義
## Secrets Manager
output "secretsmanager_secret_arns" {
  description = "マップ形式の全てのシークレット名とARNの一覧（Lambdaモジュールのシークレット関連で使用）"
  value       = { for k, v in aws_secretsmanager_secret.terra_secretsmanager_secret : k => v.arn }
}

output "secretsmanager_master_credentials_json" {
  description = "マスターユーザーの認証情報（RDSモジュールのmaster_usernameとmaster_passwordに使用）"
  value       = aws_secretsmanager_secret_version.terra_secretsmanager_secret_version[
                  [for s in var.secrets_list : s.name if s.name == "master"][0]
                ].secret_string
}