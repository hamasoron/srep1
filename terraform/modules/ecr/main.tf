# リソースの定義
## ローカル変数（ECRリポジトリ名のリストを定義）
locals {
  repository_map = { for repo in var.ecr_repositories : repo.name => repo }
  }

## ECRリポジトリの作成
resource "aws_ecr_repository" "terra_ecr_repository" {
  for_each             = local.repository_map
  name                 = "${var.system_name}-${var.environment_name}-${each.key}-repo"
  image_tag_mutability = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = lookup(each.value, "scan_on_push", true)
  }
  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key = var.ecr_kms_key
  }
  force_delete = var.ecr_force_delete
  tags = {
    Name        = "${var.system_name}-${var.environment_name}-${each.key}-repo"
    Description = each.value.description
  }
}

## ライフサイクルポリシーの作成
resource "aws_ecr_lifecycle_policy" "terra_ecr_lifecycle_policy" {
  for_each = {
    for k, v in local.repository_map :
    k => v if lookup(v, "enable_lifecycle", true)
  }
  repository = aws_ecr_repository.terra_ecr_repository[each.key].name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "untagged images are deleted after 30 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep the latest ${lookup(each.value, "lifecycle_count", 5)} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = lookup(each.value, "lifecycle_count", 5)
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}