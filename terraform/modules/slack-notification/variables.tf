# # 変数の定義
# ## 全般
# variable "system_name" {
#   description = "システム名"
#   type        = string
# }

# variable "environment_name" {
#   description = "環境名"
#   type        = string
# }

# ## Lambda
# variable "create_lambda" {
#   description = "Lambda関数を作成するかどうか"
#   type        = bool
#   default     = true
# }

# variable "function_name" {
#   description = "Lambda関数名（指定しない場合は自動生成）"
#   type        = string
#   default     = ""
# }

# variable "lambda_timeout" {
#   description = "Lambda関数のタイムアウト（秒）"
#   type        = number
#   default     = 60
# }

# variable "lambda_memory_size" {
#   description = "Lambda関数のメモリサイズ（MB）"
#   type        = number
#   default     = 128
# }

# variable "lambda_runtime" {
#   description = "Lambda関数のランタイム"
#   type        = string
#   default     = "python3.11"
# }

# variable "reserved_concurrent_executions" {
#   description = "Lambda関数の予約済み同時実行数"
#   type        = number
#   default     = -1
# }

# variable "lambda_description" {
#   description = "Lambda関数の説明"
#   type        = string
#   default     = "Lambda function for Slack notifications"
# }

# variable "dead_letter_config_target_arn" {
#   description = "デッドレターキューのターゲットARN"
#   type        = string
#   default     = ""
# }

# ## Slack
# variable "slack_webhook_url" {
#   description = "SlackのWebhook URL"
#   type        = string
#   sensitive   = true
# }

# variable "slack_channel" {
#   description = "Slackチャンネル名"
#   type        = string
#   default     = "#security-alerts"
# }

# variable "slack_username" {
#   description = "Slackに投稿するユーザー名"
#   type        = string
#   default     = "AWS-Security-Bot"
# }

# variable "slack_icon_emoji" {
#   description = "Slackアイコンの絵文字"
#   type        = string
#   default     = ":shield:"
# }

# ## CloudWatch Logs
# variable "log_retention_in_days" {
#   description = "CloudWatch Logsの保存期間（日数）"
#   type        = number
#   default     = 14
# }

# ## 環境変数
# variable "additional_environment_variables" {
#   description = "追加の環境変数"
#   type        = map(string)
#   default     = {}
# }

# ## その他
# variable "tags" {
#   description = "リソースに適用するタグ"
#   type        = map(string)
#   default     = {}
# } 