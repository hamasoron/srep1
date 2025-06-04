# アウトプットの定義
## VPC Flow Logs
output "vpc_flow_log_arn" {
  description = "VPC Flow LogのARN（作成された場合のみ）"
  value       = length(aws_flow_log.terra_flow_log) > 0 ? aws_flow_log.terra_flow_log[0].arn : null
}