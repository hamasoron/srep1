# アウトプットの定義
## Lambda関数
output "lambda_master_function_arn" {
  description = "マスターユーザー用Lambda関数のARN"
  value       = aws_lambda_function.terra_lambda_function_master_rotation.arn
}

output "lambda_app_function_arn" {
  description = "アプリユーザー用Lambda関数のARN"
  value       = aws_lambda_function.terra_lambda_function_app_rotation.arn
}

output "lambda_master_rotation_function_arn" {
  description = "マスターローテーション用Lambda関数のARN"
  value       = aws_lambda_function.terra_lambda_function_master_rotation.arn
}

output "lambda_app_rotation_function_arn" {
  description = "アプリローテーション用Lambda関数のARN"
  value       = aws_lambda_function.terra_lambda_function_app_rotation.arn
}

output "lambda_app_rotation_function_name" {
  description = "アプリローテーション用Lambda関数の名前"
  value       = aws_lambda_function.terra_lambda_function_app_rotation.function_name
}