# ローカル変数の定義
## 有効化されたルールのみをフィルタリング
locals {
  enabled_managed_rules = {
    for key, rule in var.waf_managed_rules : key => rule if rule.enabled
  }
  ### レート制限ルールの優先度（固定値で安全に設定）
  rate_limit_priority = 100
}

# リソースの定義
## Web ACLの作成（WCU: 最大1500以内に調整。将来的な拡張性を意識して1200前後を目標）
### ベースラインルールグループ＋ユースケース別ルールグループ＋IPレピュテーションルールグループでアプローチ
resource "aws_wafv2_web_acl" "terra_wafv2_web_acl" {
  name        = "${var.system_name}-${var.environment_name}-webacl"
  description = "Web ACL for ${var.system_name} ${var.environment_name}"
  scope       = var.scope
  default_action {
    allow {}
  }
  #### ライフサイクル設定でリソースの作成順序を制御
  lifecycle {
    create_before_destroy = true
  }
  ##### AWS Managed Rulesの設定 - 動的ルール生成
  dynamic "rule" {
    for_each = local.enabled_managed_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority
      dynamic "override_action" {
        for_each = rule.value.override_action == "count" ? [1] : []
        content {
          count {}
        }
      }
      dynamic "override_action" {
        for_each = rule.value.override_action == "none" ? [1] : []
        content {
          none {}
        }
      }
      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = rule.value.vendor_name
          # 除外ルールの設定
          dynamic "rule_action_override" {
            for_each = rule.value.excluded_rules
            content {
              action_to_use {
                count {}
              }
              name = rule_action_override.value
            }
          }
          # スコープダウンステートメントの設定
          dynamic "scope_down_statement" {
            for_each = rule.value.scope_down_statement != null ? [rule.value.scope_down_statement] : []
            content {
              dynamic "geo_match_statement" {
                for_each = scope_down_statement.value.geo_match_statement != null ? [scope_down_statement.value.geo_match_statement] : []
                content {
                  country_codes = geo_match_statement.value.country_codes
                }
              }
            }
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.metric_name != null ? rule.value.metric_name : "${rule.value.name}Metric"
        sampled_requests_enabled   = true
      }
    }
  }
  #### レート制限ルールの設定（WCU: 合計2）
  dynamic "rule" {
    for_each = var.enable_rate_limit ? [1] : []
    content {
      name     = "RateLimitRule"
      priority = local.rate_limit_priority
      action {
        block {}
      }
      statement {
        rate_based_statement {
          limit              = var.rate_limit_requests_per_5_minutes
          aggregate_key_type = "IP"
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "RateLimitRuleMetric"
        sampled_requests_enabled   = true
      }
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.system_name}-${var.environment_name}-web-acl-metric"
    sampled_requests_enabled   = true
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-webacl"
  }
}

## WAFと他AWSリソースの関連付け（なお、CloudFrontは非対応でCloudFrontモジュール側で関連付ける）
resource "aws_wafv2_web_acl_association" "terra_wafv2_web_acl_association" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.terra_wafv2_web_acl.arn
  depends_on = [aws_wafv2_web_acl.terra_wafv2_web_acl]
}

## WAFのログ設定
resource "aws_wafv2_web_acl_logging_configuration" "terra_wafv2_web_acl_logging_configuration" {
  count = var.enable_logging ? 1 : 0
  log_destination_configs = [var.s3_waf_logs_bucket_arn]
  resource_arn           = aws_wafv2_web_acl.terra_wafv2_web_acl.arn
  dynamic "redacted_fields" {
    for_each = var.redacted_headers
    content {
      single_header {
        name = redacted_fields.value
      }
    }
  }
  depends_on = [aws_wafv2_web_acl.terra_wafv2_web_acl]
} 