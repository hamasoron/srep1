# # WAF Web ACL
# resource "aws_wafv2_web_acl" "main" {
#   name        = "${var.system_name}-${var.environment_name}-web-acl"
#   description = "WAF Web ACL for ${var.system_name} ${var.environment_name} environment"
#   scope       = "REGIONAL"

#   default_action {
#     allow {}
#   }

#   # AWS Managed Rules
#   rule {
#     name     = "AWSManagedRulesCommonRuleSet"
#     priority = 1

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AWSManagedRulesCommonRuleSetMetric"
#       sampled_requests_enabled   = true
#     }
#   }

#   rule {
#     name     = "AWSManagedRulesKnownBadInputsRuleSet"
#     priority = 2

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesKnownBadInputsRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AWSManagedRulesKnownBadInputsRuleSetMetric"
#       sampled_requests_enabled   = true
#     }
#   }

#   rule {
#     name     = "AWSManagedRulesSQLiRuleSet"
#     priority = 3

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesSQLiRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AWSManagedRulesSQLiRuleSetMetric"
#       sampled_requests_enabled   = true
#     }
#   }

#   rule {
#     name     = "AWSManagedRulesLinuxRuleSet"
#     priority = 4

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesLinuxRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AWSManagedRulesLinuxRuleSetMetric"
#       sampled_requests_enabled   = true
#     }
#   }

#   rule {
#     name     = "AWSManagedRulesAnonymousIpList"
#     priority = 5

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesAnonymousIpList"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AWSManagedRulesAnonymousIpListMetric"
#       sampled_requests_enabled   = true
#     }
#   }

#   # レート制限ルール（カスタム）
#   dynamic "rule" {
#     for_each = var.enable_rate_limit ? [1] : []
#     content {
#       name     = "RateLimitRule"
#       priority = 6

#       action {
#         block {}
#       }

#       statement {
#         rate_based_statement {
#           limit              = var.rate_limit_requests_per_5_minutes
#           aggregate_key_type = "IP"
#         }
#       }

#       visibility_config {
#         cloudwatch_metrics_enabled = true
#         metric_name                = "RateLimitRuleMetric"
#         sampled_requests_enabled   = true
#       }
#     }
#   }

#   # CloudWatch Logging設定
#   dynamic "logging_configuration" {
#     for_each = var.enable_logging ? [1] : []
#     content {
#       log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_logs[0].arn]
#       redacted_fields {
#         dynamic "single_header" {
#           for_each = var.redacted_headers
#           content {
#             name = single_header.value
#           }
#         }
#       }
#     }
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "${var.system_name}-${var.environment_name}-web-acl-metric"
#     sampled_requests_enabled   = true
#   }

#   tags = var.tags
# }

# # WAF Logging用のKinesis Firehose
# resource "aws_kinesis_firehose_delivery_stream" "waf_logs" {
#   count       = var.enable_logging ? 1 : 0
#   name        = "${var.system_name}-${var.environment_name}-waf-logs"
#   destination = "extended_s3"

#   extended_s3_configuration {
#     role_arn   = aws_iam_role.firehose_role[0].arn
#     bucket_arn = aws_s3_bucket.waf_logs[0].arn
#     prefix     = "waf-logs/"
#   }

#   tags = var.tags
# }

# # WAF Logging用のS3バケット
# resource "aws_s3_bucket" "waf_logs" {
#   count  = var.enable_logging ? 1 : 0
#   bucket = "${var.system_name}-${var.environment_name}-waf-logs-${random_string.bucket_suffix[0].result}"

#   tags = var.tags
# }

# # S3バケットのライフサイクル設定
# resource "aws_s3_bucket_lifecycle_configuration" "waf_logs" {
#   count  = var.enable_logging ? 1 : 0
#   bucket = aws_s3_bucket.waf_logs[0].id

#   rule {
#     id     = "waf_logs_lifecycle"
#     status = "Enabled"

#     expiration {
#       days = var.log_retention_days
#     }
#   }
# }

# # S3バケットのバージョニング設定
# resource "aws_s3_bucket_versioning" "waf_logs" {
#   count  = var.enable_logging ? 1 : 0
#   bucket = aws_s3_bucket.waf_logs[0].id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# # S3バケットの暗号化設定
# resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs" {
#   count  = var.enable_logging ? 1 : 0
#   bucket = aws_s3_bucket.waf_logs[0].id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# # S3バケットのパブリックアクセスブロック設定
# resource "aws_s3_bucket_public_access_block" "waf_logs" {
#   count  = var.enable_logging ? 1 : 0
#   bucket = aws_s3_bucket.waf_logs[0].id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# # ランダム文字列（S3バケット名の重複回避用）
# resource "random_string" "bucket_suffix" {
#   count   = var.enable_logging ? 1 : 0
#   length  = 8
#   special = false
#   upper   = false
# } 