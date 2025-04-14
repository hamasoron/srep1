output "api_python_repository_url" {
  description = "API PythonリポジトリのURL"
  value       = aws_ecr_repository.api_python.repository_url
}

output "db_init_repository_url" {
  description = "DB初期化リポジトリのURL"
  value       = aws_ecr_repository.db_init.repository_url
}

output "front_nginx_repository_url" {
  description = "Front NginxリポジトリのURL"
  value       = aws_ecr_repository.front_nginx.repository_url
}

output "api_python_repository_arn" {
  description = "API PythonリポジトリのARN"
  value       = aws_ecr_repository.api_python.arn
}

output "db_init_repository_arn" {
  description = "DB初期化リポジトリのARN"
  value       = aws_ecr_repository.db_init.arn
}

output "front_nginx_repository_arn" {
  description = "Front NginxリポジトリのARN"
  value       = aws_ecr_repository.front_nginx.arn
} 