# # リソースの定義
# ## GuardDuty detector の作成
# resource "aws_guardduty_detector" "main" {
#   count = var.enable_guardduty ? 1 : 0
  
#   enable                       = true
#   finding_publishing_frequency = var.finding_publishing_frequency
  
#   # マルウェア保護の設定
#   dynamic "malware_protection" {
#     for_each = var.enable_malware_protection ? [1] : []
#     content {
#       scan_ec2_instance_with_findings {
#         ebs_volumes = true
#       }
#     }
#   }

#   # データソースの設定
#   datasources {
#     # S3ログの設定
#     s3_logs {
#       enable = var.enable_s3_protection
#     }
    
#     # Kubernetesログの設定
#     kubernetes {
#       audit_logs {
#         enable = var.enable_kubernetes_protection
#       }
#     }
    
#     # マルウェア保護の設定
#     malware_protection {
#       scan_ec2_instance_with_findings {
#         ebs_volumes {
#           enable = var.enable_malware_protection
#         }
#       }
#     }
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name        = "${var.system_name}-${var.environment_name}-guardduty-detector"
#       SystemName  = var.system_name
#       Environment = var.environment_name
#     }
#   )
# }

# ## Lambda保護の設定
# resource "aws_guardduty_detector_feature" "lambda_network_logs" {
#   count = var.enable_guardduty && var.enable_lambda_protection ? 1 : 0
  
#   detector_id = aws_guardduty_detector.main[0].id
#   name        = "LAMBDA_NETWORK_LOGS"
#   status      = "ENABLED"
# }

# ## RDS保護の設定
# resource "aws_guardduty_detector_feature" "rds_login_events" {
#   count = var.enable_guardduty && var.enable_rds_protection ? 1 : 0
  
#   detector_id = aws_guardduty_detector.main[0].id
#   name        = "RDS_LOGIN_EVENTS"
#   status      = "ENABLED"
# }

# ## ランタイム監視の設定
# resource "aws_guardduty_detector_feature" "runtime_monitoring" {
#   count = var.enable_guardduty && var.enable_runtime_monitoring ? 1 : 0
  
#   detector_id = aws_guardduty_detector.main[0].id
#   name        = "RUNTIME_MONITORING"
#   status      = "ENABLED"
  
#   additional_configuration {
#     name   = "EKS_ADDON_MANAGEMENT"
#     status = "ENABLED"
#   }
  
#   additional_configuration {
#     name   = "ECS_FARGATE_AGENT_MANAGEMENT"
#     status = "ENABLED"
#   }
  
#   additional_configuration {
#     name   = "EC2_AGENT_MANAGEMENT"
#     status = "ENABLED"
#   }
# }

# # CloudWatch Events ルール（GuardDuty検出結果用）
# resource "aws_cloudwatch_event_rule" "guardduty_findings" {
#   count = var.enable_guardduty && var.cloudwatch_event_rule_enabled ? 1 : 0
  
#   name        = "${var.system_name}-${var.environment_name}-guardduty-findings"
#   description = "GuardDuty 検出結果をキャプチャ"

#   event_pattern = jsonencode({
#     source        = ["aws.guardduty"]
#     detail-type   = ["GuardDuty Finding"]
#   })

#   tags = merge(
#     var.tags,
#     {
#       Name        = "${var.system_name}-${var.environment_name}-guardduty-findings-rule"
#       SystemName  = var.system_name
#       Environment = var.environment_name
#     }
#   )
# }

# ## CloudWatch Events ターゲット（SNSトピックが指定されている場合）
# resource "aws_cloudwatch_event_target" "sns" {
#   count = var.enable_guardduty && var.cloudwatch_event_rule_enabled && var.sns_topic_arn != "" ? 1 : 0
  
#   rule      = aws_cloudwatch_event_rule.guardduty_findings[0].name
#   target_id = "SendToSNS"
#   arn       = var.sns_topic_arn
# }

# ## CloudWatch Log Group（GuardDuty検出結果のログ保存用）
# resource "aws_cloudwatch_log_group" "guardduty" {
#   count = var.enable_guardduty ? 1 : 0
  
#   name              = "/aws/guardduty/${var.system_name}-${var.environment_name}"
#   retention_in_days = 90

#   tags = merge(
#     var.tags,
#     {
#       Name        = "${var.system_name}-${var.environment_name}-guardduty-logs"
#       SystemName  = var.system_name
#       Environment = var.environment_name
#     }
#   )
# }

# ## CloudWatch Events ターゲット（ログ出力用）
# resource "aws_cloudwatch_event_target" "logs" {
#   count = var.enable_guardduty && var.cloudwatch_event_rule_enabled ? 1 : 0
  
#   rule      = aws_cloudwatch_event_rule.guardduty_findings[0].name
#   target_id = "SendToCloudWatchLogs"
#   arn       = aws_cloudwatch_log_group.guardduty[0].arn
# } 