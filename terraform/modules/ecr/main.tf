# リソースの定義
## ローカル変数（ECRリポジトリ名のリストを定義）
locals {
  repositories = {
    "api-python" = "APIサービス用リポジトリ"
    "db-init"    = "データベース初期化用リポジトリ"
    "front-nginx" = "フロントエンドNginx用リポジトリ"
  }
  
  policy_description = "最新の${var.ecr_lifecycle_policy_count}イメージを保持"
}

## ECRリポジトリの作成
resource "aws_ecr_repository" "repositories" {
  for_each             = local.repositories
  name                 = "${var.system_name}-${var.environment_name}-${each.key}-repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name        = "${var.system_name}-${var.environment_name}-${each.key}-repo"
    Description = each.value
  }
}

## ライフサイクルポリシーの作成
resource "aws_ecr_lifecycle_policy" "policies" {
  for_each   = var.enable_ecr_lifecycle_policy ? local.repositories : {}
  repository = aws_ecr_repository.repositories[each.key].name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = local.policy_description
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.ecr_lifecycle_policy_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}