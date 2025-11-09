# アウトプットの定義
## ChatBot
output "chatbot_slack_channel_id" {
  description = "Slack channel ID configured for notifications"
  value       = var.slack_channel_id
} 