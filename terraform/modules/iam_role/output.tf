# アウトプットの定義
## IAM Role
output "iam_role_ecs_task_role_arn" {
  description = "ARN of the ECS task role (used by ECS module.)"
  value       = aws_iam_role.terra_iam_role_ecs_task.arn
}

output "iam_role_ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role (used by ECS module.)"
  value       = aws_iam_role.terra_iam_role_ecs_task_execution.arn
}

output "iam_role_lambda_master_rotation_arn" {
  description = "ARN of the master user Lambda function role (used by Lambda module.)"
  value       = aws_iam_role.terra_iam_role_lambda_master_rotation.arn
}

output "iam_role_lambda_app_rotation_arn" {
  description = "ARN of the app user Lambda function role (used by Lambda module.)"
  value       = aws_iam_role.terra_iam_role_lambda_app_rotation.arn
}

output "iam_role_github_actions_role_arn" {
  description = "ARN of the GitHub Actions role (used for copying to AWS_ROLE_TO_ASSUME in GitHub Secrets and Variables)"
  value       = aws_iam_role.terra_iam_role_github_actions.arn
}
