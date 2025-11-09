# アウトプットの定義
## SNS
output "sns_guardduty_topic_arn" {
  description = "ARN of SNS topic for GuardDuty findings（used in the EventBridge module）"
  value       = aws_sns_topic.terra_sns_topic_guardduty.arn
}