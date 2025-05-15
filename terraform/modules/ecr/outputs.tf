# アウトプットの定義
output "repositories_url" {
  description = "ECRリポジトリのURL（マップ形式）"
  value = {
    api_python  = aws_ecr_repository.terra_ecr_repository["api-python"].repository_url
    db_initdata = aws_ecr_repository.terra_ecr_repository["db-initdata"].repository_url
    front_nginx = aws_ecr_repository.terra_ecr_repository["front-nginx"].repository_url
  }
}

output "repositories_arn" {
  description = "ECRリポジトリのARN（マップ形式）"
  value = {
    api_python  = aws_ecr_repository.terra_ecr_repository["api-python"].arn
    db_initdata = aws_ecr_repository.terra_ecr_repository["db-initdata"].arn
    front_nginx = aws_ecr_repository.terra_ecr_repository["front-nginx"].arn
  }
}

output "api_repository_url" {
  description = "APIリポジトリのURL (ECS連携用)"
  value       = aws_ecr_repository.terra_ecr_repository["api-python"].repository_url
}

output "front_repository_url" {
  description = "フロントエンドリポジトリのURL (ECS連携用)"
  value       = aws_ecr_repository.terra_ecr_repository["front-nginx"].repository_url
} 

output "db_initdata_repository_url" {
  description = "データ投入用リポジトリのURL (ECS連携用)"
  value       = aws_ecr_repository.terra_ecr_repository["db-initdata"].repository_url
} 