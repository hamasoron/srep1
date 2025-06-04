# # モジュール分割後のセキュリティ統合例
# # CloudTrail + GuardDuty + EventBridge + SNS + Slack通知を個別モジュールで構成

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
#   is_multi_region_trail                    = true
#   include_global_service_events            = true
#   enable_log_file_validation               = true
#   event_selector_include_management_events = true
#   event_selector_read_write_type           = "All"
#   enable_data_events                       = false
#   enable_insight_events                    = false
#   cloudwatch_logs_group_retention_days     = 90
#   s3_bucket_force_destroy                  = false

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

#   enable_guardduty                 = true
#   finding_publishing_frequency     = "FIFTEEN_MINUTES"
#   enable_malware_protection        = true
#   enable_kubernetes_protection     = true
#   enable_runtime_monitoring        = true
#   enable_lambda_protection         = true
#   enable_rds_protection            = true
#   enable_s3_protection             = true
#   cloudwatch_event_rule_enabled    = false  # EventBridgeモジュールで管理

#   tags = {
#     Environment = var.environment_name
#     Purpose     = "Threat-Detection"
#     Owner       = "SecurityTeam"
#   }

#   depends_on = [module.cloudtrail]
# }

# # 3. SNSモジュール - 通知トピック作成
# module "sns" {
#   source = "../modules/sns"

#   system_name      = var.system_name
#   environment_name = var.environment_name

#   create_sns_topic    = true
#   display_name        = "GuardDuty Security Alerts"
#   enable_encryption   = true
#   create_kms_key      = true

#   tags = {
#     Environment = var.environment_name
#     Purpose     = "Security-Alerting"
#     Owner       = "SecurityTeam"
#   }
# }

# # 4. Slack通知モジュール - Lambda関数作成（Webhook URLが提供された場合のみ）
# module "slack_notification" {
#   count = var.slack_webhook_url != "" ? 1 : 0
  
#   source = "../modules/slack-notification"

#   system_name      = var.system_name
#   environment_name = var.environment_name

#   create_lambda        = true
#   slack_webhook_url    = var.slack_webhook_url
#   slack_channel        = "#security-alerts"
#   slack_username       = "AWS-GuardDuty-Bot"
#   slack_icon_emoji     = ":shield:"
#   lambda_timeout       = 30
#   lambda_memory_size   = 128
#   log_retention_in_days = 14

#   tags = {
#     Environment = var.environment_name
#     Purpose     = "Security-Alerting"
#     Owner       = "SecurityTeam"
#   }
# }

# # 5. EventBridgeモジュール - GuardDuty検出結果をターゲットに配信
# module "eventbridge" {
#   source = "../modules/eventbridge"

#   system_name      = var.system_name
#   environment_name = var.environment_name

#   enable_eventbridge = true
#   rule_description   = "GuardDuty検出結果を処理するEventBridgeルール"
  
#   # GuardDuty検出結果のイベントパターン（中〜高重要度のみ）
#   event_pattern = jsonencode({
#     source      = ["aws.guardduty"]
#     detail-type = ["GuardDuty Finding"]
#     detail = {
#       severity = [
#         { "numeric": [">=", 4.0] }  # MEDIUM以上
#       ]
#     }
#   })

#   # ターゲット設定（SNSとLambda）
#   targets = concat(
#     [
#       {
#         target_id = "SendToSNS"
#         arn       = module.sns.sns_topic_arn
#       }
#     ],
#     var.slack_webhook_url != "" ? [
#       {
#         target_id = "SendToSlack"
#         arn       = module.slack_notification[0].lambda_function_arn
#       }
#     ] : []
#   )

#   tags = {
#     Environment = var.environment_name
#     Purpose     = "Security-Event-Routing"
#     Owner       = "SecurityTeam"
#   }

#   depends_on = [module.guardduty, module.sns]
# }

# # SNSトピックポリシー（EventBridge用）
# data "aws_iam_policy_document" "sns_topic_policy" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["events.amazonaws.com"]
#     }
#     actions   = ["sns:Publish"]
#     resources = [module.sns.sns_topic_arn]
#     condition {
#       test     = "StringEquals"
#       variable = "aws:SourceAccount"
#       values   = [data.aws_caller_identity.current.account_id]
#     }
#   }
# }

# resource "aws_sns_topic_policy" "guardduty_alerts_policy" {
#   arn    = module.sns.sns_topic_arn
#   policy = data.aws_iam_policy_document.sns_topic_policy.json
# }

# # Lambda関数の実行許可（EventBridge用）
# resource "aws_lambda_permission" "allow_eventbridge" {
#   count = var.slack_webhook_url != "" ? 1 : 0
  
#   statement_id  = "AllowExecutionFromEventBridge"
#   action        = "lambda:InvokeFunction"
#   function_name = module.slack_notification[0].lambda_function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = module.eventbridge.eventbridge_rule_arn
# }

# # データソース
# data "aws_caller_identity" "current" {}

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

# output "sns_info" {
#   description = "SNS情報"
#   value = {
#     topic_name        = module.sns.sns_topic_name
#     topic_arn         = module.sns.sns_topic_arn
#     kms_key_id        = module.sns.kms_key_id
#     encryption_enabled = module.sns.encryption_enabled
#   }
# }

# output "eventbridge_info" {
#   description = "EventBridge情報"
#   value = {
#     rule_name = module.eventbridge.eventbridge_rule_name
#     rule_arn  = module.eventbridge.eventbridge_rule_arn
#     targets   = module.eventbridge.eventbridge_targets
#   }
# }

# output "slack_notification_info" {
#   description = "Slack通知情報"
#   value = var.slack_webhook_url != "" ? {
#     lambda_function_name = module.slack_notification[0].lambda_function_name
#     lambda_function_arn  = module.slack_notification[0].lambda_function_arn
#     log_group_name       = module.slack_notification[0].lambda_log_group_name
#     slack_channel        = module.slack_notification[0].slack_channel
#   } : null
# }

# output "security_dashboard_urls" {
#   description = "セキュリティダッシュボードのURL"
#   value = {
#     cloudtrail = "https://console.aws.amazon.com/cloudtrail/home"
#     guardduty  = "https://console.aws.amazon.com/guardduty/home"
#     eventbridge = "https://console.aws.amazon.com/events/home"
#     sns        = "https://console.aws.amazon.com/sns/v3/home"
#     lambda     = var.slack_webhook_url != "" ? "https://console.aws.amazon.com/lambda/home" : null
#   }
# } 