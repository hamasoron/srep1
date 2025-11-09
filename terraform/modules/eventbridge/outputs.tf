# アウトプットの定義
## EventBridge
output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.terra_cloudwatch_event_rule_guardduty.arn
}