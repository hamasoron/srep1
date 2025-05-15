# リソースの定義
## ECSログ用のCloudWatchロググループを作成
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  for_each          = { for service in var.services : service.name => service }
  name              = "/ecs/${var.system_name}-${var.environment_name}-${each.key}-taskdef"
  retention_in_days = var.log_retention_days
  tags = {
    Name = "${var.system_name}-${var.environment_name}-${each.key}-logs"
  }
}