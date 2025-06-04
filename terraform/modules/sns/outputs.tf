# アウトプットの定義
## SNS
output "sns_topic_name" {
  description = "SNSトピックの名前"
  value       = var.create_sns_topic ? aws_sns_topic.main[0].name : null
}

output "sns_topic_arn" {
  description = "SNSトピックのARN"
  value       = var.create_sns_topic ? aws_sns_topic.main[0].arn : null
}

output "sns_topic_id" {
  description = "SNSトピックのID"
  value       = var.create_sns_topic ? aws_sns_topic.main[0].id : null
}

output "sns_topic_display_name" {
  description = "SNSトピックの表示名"
  value       = var.create_sns_topic ? aws_sns_topic.main[0].display_name : null
}

output "sns_topic_policy" {
  description = "SNSトピックのポリシー"
  value       = var.create_sns_topic ? aws_sns_topic.main[0].policy : null
}

output "sns_topic_owner" {
  description = "SNSトピックの所有者"
  value       = var.create_sns_topic ? aws_sns_topic.main[0].owner : null
}

## KMS
output "kms_key_id" {
  description = "SNS暗号化用KMSキーのID"
  value       = var.create_sns_topic && var.enable_encryption && var.create_kms_key ? aws_kms_key.sns[0].id : null
}

output "kms_key_arn" {
  description = "SNS暗号化用KMSキーのARN"
  value       = var.create_sns_topic && var.enable_encryption && var.create_kms_key ? aws_kms_key.sns[0].arn : null
}

output "kms_alias_name" {
  description = "SNS暗号化用KMSキーのエイリアス名"
  value       = var.create_sns_topic && var.enable_encryption && var.create_kms_key ? aws_kms_alias.sns[0].name : null
}

output "kms_alias_arn" {
  description = "SNS暗号化用KMSキーのエイリアスARN"
  value       = var.create_sns_topic && var.enable_encryption && var.create_kms_key ? aws_kms_alias.sns[0].arn : null
}

## 設定情報
output "encryption_enabled" {
  description = "SNS暗号化が有効かどうか"
  value       = var.enable_encryption
}

output "kms_key_created" {
  description = "KMSキーが作成されたかどうか"
  value       = var.create_kms_key
} 