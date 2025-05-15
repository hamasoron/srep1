# アウトプットの定義
## CloudWatch Logs
output "log_group_names" {
  description = "作成されたCloudWatch Logsグループの名前のマップ"
  value       = { for k, v in aws_cloudwatch_log_group.ecs_log_group : k => v.name }
}

# output "log_group_arns" {
#   description = "作成されたCloudWatch Logsグループのarnのマップ"
#   value       = { for k, v in aws_cloudwatch_log_group.ecs_log_group : k => v.arn }
# }

# output "service_connect_log_group_names" {
#   description = "作成されたService Connect用CloudWatch Logsグループの名前のマップ"
#   value       = { for k, v in aws_cloudwatch_log_group.service_connect_log_group : k => v.name }
# }

# output "service_connect_log_group_arns" {
#   description = "作成されたService Connect用CloudWatch Logsグループのarnのマップ"
#   value       = { for k, v in aws_cloudwatch_log_group.service_connect_log_group : k => v.arn }
# } 