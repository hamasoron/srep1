# リソースの定義
## ローカル変数（ECRリポジトリ名のリストを定義）
locals {
  repositories = {
    "api-python"  = "APIサービス用リポジトリ"
    "db-initdata" = "データ投入用リポジトリ"
    "front-nginx" = "フロントエンドNginx用リポジトリ"
  }
  policy_description = "最新の${var.ecr_lifecycle_policy_count}イメージを保持"
}

## ECRリポジトリの作成
resource "aws_ecr_repository" "terra_ecr_repository" {
  for_each             = local.repositories
  name                 = "${var.system_name}-${var.environment_name}-${each.key}-repo"
  image_tag_mutability = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key = var.ecr_kms_key
  }
  force_delete = var.ecr_force_delete
  tags = {
    Name        = "${var.system_name}-${var.environment_name}-${each.key}-repo"
    Description = each.value
  }
}

## ライフサイクルポリシーの作成
resource "aws_ecr_lifecycle_policy" "terra_ecr_lifecycle_policy" {
  for_each   = var.enable_ecr_lifecycle_policy ? local.repositories : {}
  repository = aws_ecr_repository.terra_ecr_repository[each.key].name
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