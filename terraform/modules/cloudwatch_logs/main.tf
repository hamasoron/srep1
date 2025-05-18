# リソースの定義
## RDSログ用のCloudWatchロググループを作成
resource "aws_cloudwatch_log_group" "rds_log_group" {
  for_each          = { for log_config in var.rds_log_configs : log_config.name => log_config }
  name              = "/aws/rds/cluster/${var.system_name}-${var.environment_name}-aurora-cluster/${each.key}"
  retention_in_days = each.value.retention_in_days
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-cluster-logs"
  }
}

## ECSログ用のCloudWatchロググループを作成
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  for_each          = { for log_config in var.ecs_log_configs : log_config.name => log_config }
  name              = "/ecs/${var.system_name}-${var.environment_name}-${each.key}-taskdef"
  retention_in_days = each.value.retention_in_days
  tags = {
    Name = "${var.system_name}-${var.environment_name}-${each.key}-taskdef-logs"
  }
}