# アウトプットの定義
## Lambda関数
output "lambda_master_function_arn" {
  description = "ARN of the Lambda function for the master user"
  value       = aws_lambda_function.terra_lambda_function_master_rotation.arn
}

output "lambda_app_function_arn" {
  description = "ARN of the Lambda function for the app user"
  value       = aws_lambda_function.terra_lambda_function_app_rotation.arn
}