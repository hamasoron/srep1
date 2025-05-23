# アウトプットの定義
## Lambda関数
output "lambda_function_arn" {
  description = "Lambda関数のARN"
  value       = aws_lambda_function.terra_lambda_function_rotation.arn
}