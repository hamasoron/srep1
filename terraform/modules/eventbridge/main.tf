# ローカル変数を定義
## Localsで重要度レベルを数値リストに変換
locals {
  severity_filters = {
    "low"      = [for i in range(10, 101) : i / 10.0]  ### 1.0-10.0までの数値をlowと定義 (すべて)
    "medium"   = [for i in range(40, 101) : i / 10.0]  ### 4.0-10.0までの数値をmediumと定義 (中程度以上)
    "high"     = [for i in range(70, 101) : i / 10.0]  ### 7.0-10.0までの数値をhighと定義 (重要度が高い以上)
    "critical" = [for i in range(90, 101) : i / 10.0]  ### 9.0-10.0までの数値をcriticalと定義 (重大度のみ) 
  }
  selected_severity_filter = local.severity_filters[var.severity_level]
}

# リソースの定義
## EventBridgeルールを作成（GuardDutyの検出結果をイベントソースとしてキャプチャ）
resource "aws_cloudwatch_event_rule" "terra_cloudwatch_event_rule_guardduty" {
  name        = "${var.system_name}-${var.environment_name}-guardduty-eventbridge-rule"
  description = "EventBridge rule to capture GuardDuty as event source"
  state       = var.event_rule_state
  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = local.selected_severity_filter
    }
  })
  tags = {
    Name = "${var.system_name}-${var.environment_name}-guardduty-eventbridge-rule"
  }
}

## EventBridgeターゲットを作成（GuardDutyの検出結果をSNSに送信）
resource "aws_cloudwatch_event_target" "terra_cloudwatch_event_target_sns" {
  arn       = var.sns_guardduty_topic_arn
  rule      = aws_cloudwatch_event_rule.terra_cloudwatch_event_rule_guardduty.name
  target_id = "GuardDutySNSTarget"
  ### SNSメッセージの変換設定
  input_transformer {
    input_paths = {
      severity    = "$.detail.severity"
      type        = "$.detail.type"
      region      = "$.detail.region"
      accountId   = "$.detail.accountId"
      title       = "$.detail.title"
      description = "$.detail.description"
      time        = "$.time"
    }
    input_template = jsonencode({
      alert_type = "GuardDuty Finding"
      severity   = "<severity>"
      finding_type = "<type>"
      region     = "<region>"
      account_id = "<accountId>"
      title      = "<title>"
      description = "<description>"
      timestamp  = "<time>"
      message    = "GuardDuty検出: <title> - 重要度: <severity>"
    })
  }
}