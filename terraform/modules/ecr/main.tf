# ECRリポジトリの作成
resource "aws_ecr_repository" "api_python" {
  name                 = "${var.system_name}-${var.environment_name}-api-python-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.system_name}-${var.environment_name}-api-python-repo"
  }
}

resource "aws_ecr_repository" "db_init" {
  name                 = "${var.system_name}-${var.environment_name}-db-init-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.system_name}-${var.environment_name}-db-init-repo"
  }
}

resource "aws_ecr_repository" "front_nginx" {
  name                 = "${var.system_name}-${var.environment_name}-front-nginx-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.system_name}-${var.environment_name}-front-nginx-repo"
  }
} 