# アウトプットの定義
## VPC Flow Logs
output "vpc_flow_log_arn" {
  description = "ARN of the VPC Flow Log (only if created)"
  value       = length(aws_flow_log.terra_flow_log) > 0 ? aws_flow_log.terra_flow_log[0].arn : null
}