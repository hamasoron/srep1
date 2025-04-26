# アウトプットの定義
output "repositories_url" {
  description = "ECRリポジトリのURL（マップ形式）"
  value = {
    api_python  = aws_ecr_repository.repositories["api-python"].repository_url
    db_init     = aws_ecr_repository.repositories["db-init"].repository_url
    front_nginx = aws_ecr_repository.repositories["front-nginx"].repository_url
  }
}

output "repositories_arn" {
  description = "ECRリポジトリのARN（マップ形式）"
  value = {
    api_python  = aws_ecr_repository.repositories["api-python"].arn
    db_init     = aws_ecr_repository.repositories["db-init"].arn
    front_nginx = aws_ecr_repository.repositories["front-nginx"].arn
  }
}

output "api_repository_url" {
  description = "APIリポジトリのURL (ECS連携用)"
  value       = aws_ecr_repository.repositories["api-python"].repository_url
}

output "front_repository_url" {
  description = "フロントエンドリポジトリのURL (ECS連携用)"
  value       = aws_ecr_repository.repositories["front-nginx"].repository_url
} 