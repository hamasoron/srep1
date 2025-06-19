# アウトプットの定義
## CloudWatch Logs
output "rds_log_group_names" {
  description = "Map of CloudWatch log group names (used by RDS module)"
  value = {
    for name, lg in aws_cloudwatch_log_group.rds_log_group :
    name => lg.name
  }
}

output "ecs_log_group_names" {
  description = "Map of CloudWatch log group names (used by ECS module)"
  value = {
    for name, lg in aws_cloudwatch_log_group.ecs_log_group :
    name => lg.name
  }
}

output "lambda_log_group_names" {
  description = "Map of CloudWatch log group names (used by Lambda module)"
  value = {
    for name, lg in aws_cloudwatch_log_group.lambda_log_group :
    name => lg.name
  }
}