# # アウトプットの定義
# ## Lambda
# output "lambda_function_name" {
#   description = "Slack通知用Lambda関数の名前"
#   value       = var.create_lambda ? aws_lambda_function.slack_notification[0].function_name : null
# }

# output "lambda_function_arn" {
#   description = "Slack通知用Lambda関数のARN"
#   value       = var.create_lambda ? aws_lambda_function.slack_notification[0].arn : null
# }

# output "lambda_function_invoke_arn" {
#   description = "Slack通知用Lambda関数の呼び出しARN"
#   value       = var.create_lambda ? aws_lambda_function.slack_notification[0].invoke_arn : null
# }

# output "lambda_function_qualified_arn" {
#   description = "Slack通知用Lambda関数の修飾ARN"
#   value       = var.create_lambda ? aws_lambda_function.slack_notification[0].qualified_arn : null
# }

# output "lambda_function_version" {
#   description = "Slack通知用Lambda関数のバージョン"
#   value       = var.create_lambda ? aws_lambda_function.slack_notification[0].version : null
# }

# output "lambda_function_last_modified" {
#   description = "Slack通知用Lambda関数の最終更新日時"
#   value       = var.create_lambda ? aws_lambda_function.slack_notification[0].last_modified : null
# }

# output "lambda_function_source_code_hash" {
#   description = "Slack通知用Lambda関数のソースコードハッシュ"
#   value       = var.create_lambda ? aws_lambda_function.slack_notification[0].source_code_hash : null
# }

# output "lambda_function_source_code_size" {
#   description = "Slack通知用Lambda関数のソースコードサイズ"
#   value       = var.create_lambda ? aws_lambda_function.slack_notification[0].source_code_size : null
# }

# ## IAM
# output "lambda_role_name" {
#   description = "Lambda実行用IAMロールの名前"
#   value       = var.create_lambda ? aws_iam_role.lambda_execution_role[0].name : null
# }

# output "lambda_role_arn" {
#   description = "Lambda実行用IAMロールのARN"
#   value       = var.create_lambda ? aws_iam_role.lambda_execution_role[0].arn : null
# }

# output "lambda_policy_name" {
#   description = "Lambda実行用IAMポリシーの名前"
#   value       = var.create_lambda ? aws_iam_policy.lambda_policy[0].name : null
# }

# output "lambda_policy_arn" {
#   description = "Lambda実行用IAMポリシーのARN"
#   value       = var.create_lambda ? aws_iam_policy.lambda_policy[0].arn : null
# }

# ## CloudWatch Logs
# output "lambda_log_group_name" {
#   description = "Lambda関数のCloudWatch Log Group名"
#   value       = var.create_lambda ? aws_cloudwatch_log_group.lambda_logs[0].name : null
# }

# output "lambda_log_group_arn" {
#   description = "Lambda関数のCloudWatch Log GroupのARN"
#   value       = var.create_lambda ? aws_cloudwatch_log_group.lambda_logs[0].arn : null
# }

# ## Slack設定情報
# output "slack_channel" {
#   description = "Slackチャンネル名"
#   value       = var.slack_channel
# }

# output "slack_username" {
#   description = "Slackユーザー名"
#   value       = var.slack_username
# }

# output "slack_icon_emoji" {
#   description = "Slackアイコンの絵文字"
#   value       = var.slack_icon_emoji
# }

# ## 設定情報
# output "lambda_timeout" {
#   description = "Lambdaタイムアウト（秒）"
#   value       = var.lambda_timeout
# }

# output "lambda_memory_size" {
#   description = "Lambdaメモリサイズ（MB）"
#   value       = var.lambda_memory_size
# }

# output "lambda_runtime" {
#   description = "Lambdaランタイム"
#   value       = var.lambda_runtime
# } 