# アウトプットの定義
output "ecr_repository_urls" {
  description = "URL of the ECR repository (used as the image URL for the task definition in the ECS module)"
  value = {
    for name, repo in aws_ecr_repository.terra_ecr_repository :
    name => repo.repository_url
  }
}