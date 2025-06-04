# # アウトプットの定義
# ## GuardDuty Detector
# output "guardduty_detector_id" {
#   description = "GuardDutyディテクターのID"
#   value       = var.enable_guardduty ? aws_guardduty_detector.main[0].id : null
# }

# output "guardduty_detector_arn" {
#   description = "GuardDutyディテクターのARN"
#   value       = var.enable_guardduty ? aws_guardduty_detector.main[0].arn : null
# }

# output "guardduty_detector_account_id" {
#   description = "GuardDutyディテクターのアカウントID"
#   value       = var.enable_guardduty ? aws_guardduty_detector.main[0].account_id : null
# }

# ## CloudWatch Events Rule
# output "cloudwatch_event_rule_name" {
#   description = "CloudWatch Events ルールの名前"
#   value       = var.enable_guardduty && var.cloudwatch_event_rule_enabled ? aws_cloudwatch_event_rule.guardduty_findings[0].name : null
# }

# output "cloudwatch_event_rule_arn" {
#   description = "CloudWatch Events ルールのARN"
#   value       = var.enable_guardduty && var.cloudwatch_event_rule_enabled ? aws_cloudwatch_event_rule.guardduty_findings[0].arn : null
# }

# ## CloudWatch Log Group
# output "cloudwatch_log_group_name" {
#   description = "CloudWatch Log GroupのLog Group名"
#   value       = var.enable_guardduty ? aws_cloudwatch_log_group.guardduty[0].name : null
# }

# output "cloudwatch_log_group_arn" {
#   description = "CloudWatch Log GroupのARN"
#   value       = var.enable_guardduty ? aws_cloudwatch_log_group.guardduty[0].arn : null
# }

# ## GuardDuty Features
# output "lambda_protection_enabled" {
#   description = "Lambda保護が有効かどうか"
#   value       = var.enable_guardduty && var.enable_lambda_protection
# }

# output "rds_protection_enabled" {
#   description = "RDS保護が有効かどうか"
#   value       = var.enable_guardduty && var.enable_rds_protection
# }

# output "runtime_monitoring_enabled" {
#   description = "ランタイム監視が有効かどうか"
#   value       = var.enable_guardduty && var.enable_runtime_monitoring
# }

# output "s3_protection_enabled" {
#   description = "S3保護が有効かどうか"
#   value       = var.enable_s3_protection
# }

# output "kubernetes_protection_enabled" {
#   description = "Kubernetes保護が有効かどうか"
#   value       = var.enable_kubernetes_protection
# }

# output "malware_protection_enabled" {
#   description = "マルウェア保護が有効かどうか"
#   value       = var.enable_malware_protection
# } # GuardDuty Detector