# アウトプットの定義
## IAM Role
output "iam_role_ecs_task_role_arn" {
  description = "ECSタスク用のIAMロールのARN（ECSモジュール等で使用）"
  value       = aws_iam_role.terra_iam_role_ecs_task.arn
}

output "iam_role_ecs_task_execution_role_arn" {
  description = "ECSタスク実行用のIAMロールのARN（ECSモジュール等で使用）"
  value       = aws_iam_role.terra_iam_role_ecs_task_execution.arn
}

output "iam_role_github_actions_role_arn" {
  description = "GitHub Actions用のIAMロールのARN（GitHubのSecrets and VariablesのAWS_ROLE_TO_ASSUMEにコピーする際に使用）"
  value       = aws_iam_role.terra_iam_role_github_actions.arn
}

output "iam_role_lambda_rotation_arn" {
  description = "Lambda関数用のIAMロールのARN（Lambda関数のモジュール呼び出し時に使用）"
  value       = aws_iam_role.terra_iam_role_lambda_rotation.arn
}