# リソースの定義
# resource "aws_cloudwatch_event_rule" "guardduty_findings" {
#   for_each = var.enable_guardduty_detector && var.cloudwatch_event_rule_enabled ? toset(local.guardduty_regions) : toset([])
#   name        = "${var.system_name}-${var.environment_name}-guardduty-findings-${each.value}"
#   description = "GuardDuty 検出結果をキャプチャ (${each.value})"
#   event_pattern = jsonencode({
#     source        = ["aws.guardduty"]
#     detail-type   = ["GuardDuty Finding"]
#   })
#   tags = {
#     Name = "${var.system_name}-${var.environment_name}-guardduty-findings-rule"
#   }
# }

# ## CloudWatch Events ターゲット（SNSトピックが指定されている場合）- マルチリージョン対応
# resource "aws_cloudwatch_event_target" "sns" {
#   for_each = var.enable_guardduty_detector && var.cloudwatch_event_rule_enabled && var.sns_topic_arn != "" ? toset(local.guardduty_regions) : toset([])
#   rule      = aws_cloudwatch_event_rule.guardduty_findings[each.key].name
#   target_id = "SendToSNS"
#   arn       = var.sns_topic_arn
# }