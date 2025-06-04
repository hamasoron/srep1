# # セキュリティ統合の使用例
# # CloudTrail + GuardDuty + EventBridge/SNS を組み合わせた包括的なセキュリティ監視

# # 変数定義
# variable "system_name" {
#   description = "システム名"
#   type        = string
#   default     = "my-security-system"
# }

# variable "environment_name" {
#   description = "環境名"
#   type        = string
#   default     = "production"
# }

# variable "slack_webhook_url" {
#   description = "SlackのWebhook URL（任意）"
#   type        = string
#   default     = ""
#   sensitive   = true
# }

# # 1. CloudTrailモジュール - 全リージョンの管理イベントを記録
# module "cloudtrail" {
#   source = "../modules/cloudtrail"

#   system_name      = var.system_name
#   environment_name = var.environment_name

#   # CloudTrail設定
#   enable_cloudtrail                        = true
#   is_multi_region_trail                    = true  # 全リージョン対応
#   include_global_service_events            = true  # グローバルサービスイベント含む
#   enable_log_file_validation               = true  # ログファイル検証

#   # イベント設定（管理イベントのみ）
#   event_selector_include_management_events = true
#   event_selector_read_write_type           = "All"  # 読み書き両方
#   enable_data_events                       = false # データイベントは無効
#   enable_insight_events                    = false # インサイトイベントは無効

#   # ログ保存設定
#   cloudwatch_logs_group_retention_days = 90
#   s3_bucket_force_destroy                = false

#   tags = {
#     Environment = var.environment_name
#     Purpose     = "Security-Audit-Logging"
#     Owner       = "SecurityTeam"
#   }
# }

# # 2. GuardDutyモジュール - CloudTrailログを監視
# module "guardduty" {
#   source = "../modules/guardduty"

#   system_name      = var.system_name
#   environment_name = var.environment_name

#   # GuardDuty基本設定
#   enable_guardduty             = true
#   finding_publishing_frequency = "FIFTEEN_MINUTES"  # 高頻度で通知

#   # 保護機能の設定
#   enable_malware_protection    = true
#   enable_kubernetes_protection = true
#   enable_runtime_monitoring    = true
#   enable_lambda_protection     = true
#   enable_rds_protection        = true
#   enable_s3_protection         = true

#   # CloudWatch Events設定
#   cloudwatch_event_rule_enabled = true
#   sns_topic_arn                 = module.eventbridge_sns.sns_topic_arn

#   tags = {
#     Environment = var.environment_name
#     Purpose     = "Threat-Detection"
#     Owner       = "SecurityTeam"
#   }

#   depends_on = [module.cloudtrail]
# }

# # 3. EventBridge/SNSモジュール - GuardDuty検出結果をSlackに通知
# module "eventbridge_sns" {
#   source = "../modules/eventbridge-sns"

#   system_name      = var.system_name
#   environment_name = var.environment_name

#   # EventBridge設定
#   enable_eventbridge = true
  
#   # 特定の重要度以上のみ通知（中〜高レベル）
#   guardduty_severity_levels = ["MEDIUM", "HIGH"]

#   # SNS設定
#   create_sns_topic      = true
#   enable_sns_encryption = true
#   sns_display_name      = "GuardDuty Security Alerts"

#   # Slack設定（Webhook URLが提供された場合のみ有効）
#   slack_webhook_url = var.slack_webhook_url
#   slack_channel     = "#security-alerts"
#   slack_username    = "AWS-GuardDuty-Bot"
#   slack_icon_emoji  = ":shield:"

#   # Lambda設定
#   lambda_timeout     = 30
#   lambda_memory_size = 128

#   tags = {
#     Environment = var.environment_name
#     Purpose     = "Security-Alerting"
#     Owner       = "SecurityTeam"
#   }

#   depends_on = [module.guardduty]
# }

# # 出力値
# output "cloudtrail_info" {
#   description = "CloudTrail情報"
#   value = {
#     arn                = module.cloudtrail.cloudtrail_arn
#     name               = module.cloudtrail.cloudtrail_name
#     s3_bucket_name     = module.cloudtrail.s3_bucket_name
#     log_group_name     = module.cloudtrail.cloudwatch_log_group_name
#     multi_region       = module.cloudtrail.is_multi_region_trail
#     management_events  = module.cloudtrail.management_events_enabled
#   }
# }

# output "guardduty_info" {
#   description = "GuardDuty情報"
#   value = {
#     detector_id                = module.guardduty.guardduty_detector_id
#     detector_arn              = module.guardduty.guardduty_detector_arn
#     malware_protection        = module.guardduty.malware_protection_enabled
#     kubernetes_protection     = module.guardduty.kubernetes_protection_enabled
#     runtime_monitoring        = module.guardduty.runtime_monitoring_enabled
#     lambda_protection         = module.guardduty.lambda_protection_enabled
#     rds_protection            = module.guardduty.rds_protection_enabled
#     s3_protection             = module.guardduty.s3_protection_enabled
#   }
# }

# output "notification_info" {
#   description = "通知システム情報"
#   value = {
#     eventbridge_rule_name = module.eventbridge_sns.eventbridge_rule_name
#     sns_topic_arn         = module.eventbridge_sns.sns_topic_arn
#     lambda_function_name  = module.eventbridge_sns.lambda_function_name
#     slack_enabled         = module.eventbridge_sns.slack_enabled
#     slack_channel         = module.eventbridge_sns.slack_channel
#   }
# }

# output "security_dashboard_urls" {
#   description = "セキュリティダッシュボードのURL"
#   value = {
#     cloudtrail = "https://console.aws.amazon.com/cloudtrail/home"
#     guardduty  = "https://console.aws.amazon.com/guardduty/home"
#     eventbridge = "https://console.aws.amazon.com/events/home"
#   }
# } 