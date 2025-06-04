# アウトプットの定義
## Secrets Manager
output "secretsmanager_secret_arns" {
  description = "Map of all secret names and ARNs (used by Lambda module for secret-related settings)"
  value       = { for k, v in aws_secretsmanager_secret.terra_secretsmanager_secret : k => v.arn }
}

output "secretsmanager_master_credentials_json" {
  description = "Master user credentials (used by RDS module for master_username and master_password)"
  value       = aws_secretsmanager_secret_version.terra_secretsmanager_secret_version[
                  [for s in var.secrets_list : s.name if s.name == "master"][0]
                ].secret_string
  sensitive   = true
}