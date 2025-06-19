# リソースの定義
## Web ACLの作成（WCU: 最大1500以内に調整。将来的な拡張性を意識して1200前後を目標）。現在: 1000 + 200 + 75 = 1275。
###「ベースラインルールグループ（約1,000WCU）＋ユースケース別ルールグループ（調整）＋IPレピュテーションルールグループ（75WCU）でアプローチ
resource "aws_wafv2_web_acl" "terra_wafv2_web_acl" {
  name        = "${var.system_name}-${var.environment_name}-webacl"
  description = "Web ACL for ${var.system_name} ${var.environment_name}"
  scope       = var.scope
  default_action {
    allow {}
  }
  #### AWS Managed Rulesの設定
  ##### ベースラインルールグループ（WCU: 合計1000）
  ###### AWSManagedRulesCommonRuleSetの設定（WCU: 700）
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    dynamic "override_action" { ##### ルールグループ内のルールのアクションの挙動を上書きするための設定（count: カウントアクションに上書き、none: 各ルールのデフォルトのアクションを使用）
      for_each = var.override_action == "count" ? [1] : []
      content {
        count {}
      }
    }
    dynamic "override_action" {
      for_each = var.override_action == "none" ? [1] : []
      content {
        none {}
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }
  ###### AWSManagedRulesAdminProtectionの設定（WCU: 100）
  rule {
    name     = "AWSManagedRulesAdminProtection"
    priority = 2
    dynamic "override_action" {
      for_each = var.override_action == "count" ? [1] : []
      content {
        count {}
      }
    }
    dynamic "override_action" {
      for_each = var.override_action == "none" ? [1] : []
      content {
        none {}
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAdminProtection"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAdminProtectionMetric"
      sampled_requests_enabled   = true
    }
  }
  ###### AWSManagedRulesKnownBadInputsRuleSetの設定（WCU: 200）
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3
    dynamic "override_action" { 
      for_each = var.override_action == "count" ? [1] : []
      content {
        count {}
      }
    }
    dynamic "override_action" {
      for_each = var.override_action == "none" ? [1] : []
      content {
        none {}
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }
  ##### ユースケース別ルールグループ（WCU: 合計200）
  ###### AWSManagedRulesSQLiRuleSetの設定（WCU: 200）
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 4
    dynamic "override_action" {
      for_each = var.override_action == "count" ? [1] : []
      content {
        count {}
      }
    }
    dynamic "override_action" {
      for_each = var.override_action == "none" ? [1] : []
      content {
        none {}
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }
  ##### IPレピュテーションルールグループ（WCU: 合計75）
  ###### AWSManagedRulesAmazonIpReputationListの設定（WCU: 25）
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 5
    dynamic "override_action" {
      for_each = var.override_action == "count" ? [1] : []
      content {
        count {}
      }
    }
    dynamic "override_action" {
      for_each = var.override_action == "none" ? [1] : []
      content {
        none {}
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationListMetric"
      sampled_requests_enabled   = true
    }
  }
  ###### AWSManagedRulesAnonymousIpListの設定（WCU: 50）
  rule {
    name     = "AWSManagedRulesAnonymousIpList"
    priority = 6
    dynamic "override_action" {
      for_each = var.override_action == "count" ? [1] : []
      content {
        count {}
      }
    }
    dynamic "override_action" {
      for_each = var.override_action == "none" ? [1] : []
      content {
        none {}
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAnonymousIpListMetric"
      sampled_requests_enabled   = true
    }
  }
  #### レート制限ルールの設定（WCU: 合計2）
  ###### IPアドレスごとのレート（5分間に○○リクエスト）（WCU: 2）
  dynamic "rule" {
    for_each = var.enable_rate_limit ? [1] : []
    content {
      name     = "RateLimitRule"
      priority = 7
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

# WAFと他AWSリソースの紐づけ（なお、CloudFrontは非対応でCloudFrontモジュール側で紐づける）
resource "aws_wafv2_web_acl_association" "terra_wafv2_web_acl_association" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.terra_wafv2_web_acl.arn
}

# WAF Logging設定（別リソース）
resource "aws_wafv2_web_acl_logging_configuration" "terra_wafv2_web_acl_logging_configuration" {
  count = var.enable_logging ? 1 : 0
  log_destination_configs = [var.s3_waf_logs_bucket_arn]
  resource_arn           = var.alb_arn
  dynamic "redacted_fields" {
    for_each = var.redacted_headers
    content {
      single_header {
        name = redacted_fields.value
      }
    }
  }
} 