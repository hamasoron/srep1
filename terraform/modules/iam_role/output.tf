# アウトプットの定義
## IAM Role
output "iam_role_ecs_task_role_arn" {
  description = "ECS task role ARN (used by ECS module.)"
  value       = aws_iam_role.terra_iam_role_ecs_task.arn
}

output "iam_role_ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN (used by ECS module.)"
  value       = aws_iam_role.terra_iam_role_ecs_task_execution.arn
}

output "iam_role_lambda_master_rotation_arn" {
  description = "Master user Lambda function role ARN (used by Lambda module.)"
  value       = aws_iam_role.terra_iam_role_lambda_master_rotation.arn
}

output "iam_role_lambda_app_rotation_arn" {
  description = "App user Lambda function role ARN (used by Lambda module.)"
  value       = aws_iam_role.terra_iam_role_lambda_app_rotation.arn
}

output "iam_role_github_actions_role_arn" {
  description = "GitHub Actions role ARN (used for copying to AWS_ROLE_TO_ASSUME in GitHub Secrets and Variables)"
  value       = aws_iam_role.terra_iam_role_github_actions.arn
}
