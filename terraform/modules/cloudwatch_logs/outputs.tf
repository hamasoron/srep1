# アウトプットの定義
## CloudWatch Logs
output "rds_log_group_names" {
  description = "マップ形式のCloudWatchロググループの名前一覧（RDSモジュールのロググループ名として使用）"
  value = {
    for name, lg in aws_cloudwatch_log_group.rds_log_group :
    name => lg.name
  }
}
output "ecs_log_group_names" {
  description = "マップ形式のCloudWatchロググループの名前一覧（ECSモジュールのタスク定義のロググループ名として使用）"
  value = {
    for name, lg in aws_cloudwatch_log_group.ecs_log_group :
    name => lg.name
  }
}