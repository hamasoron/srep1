# アウトプットの定義
## IAMロール
output "ecs_task_role_arn" {
  description = "ECSタスク用のIAMロールのARN"
  value       = aws_iam_role.terra_iam_role_ecs_task.arn
}

output "ecs_task_execution_role_arn" {
  description = "ECSタスク実行用のIAMロールのARN"
  value       = aws_iam_role.terra_iam_role_ecs_task_execution.arn
}

output "github_actions_role_arn" {
  description = "GitHub Actions用のIAMロールのARN"
  value       = aws_iam_role.terra_iam_role_github_actions.arn
}