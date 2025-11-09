# アウトプットの定義
## Amazon Q Developer
output "q_developer_slack_channel_id" {
  description = "Slack channel ID configured for notifications"
  value       = var.slack_channel_id
} 