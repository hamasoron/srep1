#　リソースの定義
## セキュリティグループの作成 - 基本セキュリティグループ
resource "aws_security_group" "terra_security_group" {
  for_each    = var.sg_definitions
  name        = "${var.system_name}-${var.environment_name}-${each.key}-sg"
  description = each.value.description
  vpc_id      = var.vpc_id

  ## インバウンドルール（cidr_blocksがあるルールのみ。他のSGを参照する場合は対象外）
  dynamic "ingress" {
    for_each = [
      for rule in each.value.ingress : rule
      if length(lookup(rule, "cidr_blocks", [])) > 0
    ]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = lookup(ingress.value, "description", null)
    }
  }

  ## アウトバウンドルール（cidr_blocksによる宛先指定）
  dynamic "egress" {
    for_each = each.value.egress
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = lookup(egress.value, "description", null)
    }
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-${each.key}-sg"
  }
  lifecycle {
    create_before_destroy = true
  }
}

## セキュリティグループIDを参照するためのローカル変数
locals {
  security_group_ids = {
    for k, v in aws_security_group.terra_security_group : k => v.id
  }
}

## ALB -> ECS-FRONT-NGINX: 80番ポート
resource "aws_security_group_rule" "ecs_front_nginx_from_alb_80" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = local.security_group_ids["ecs-front-nginx"]
  source_security_group_id = local.security_group_ids["alb"]
  description              = "Allow HTTP traffic from ALB to ECS Frontend Nginx"
}

## ECS-FRONT-NGINX -> ECS-API-PYTHON: 8080番ポート
resource "aws_security_group_rule" "ecs_api_python_from_ecs_front_nginx" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = local.security_group_ids["ecs-api-python"]
  source_security_group_id = local.security_group_ids["ecs-front-nginx"]
  description              = "Allow traffic on port 8080 from ECS Frontend Nginx to ECS API Python"
}

## ECS-API-PYTHON -> RDS: 3306番ポート
resource "aws_security_group_rule" "rds_from_ecs_api_python" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = local.security_group_ids["rds"]
  source_security_group_id = local.security_group_ids["ecs-api-python"]
  description              = "Allow MySQL traffic from ECS API Python to RDS"
}

## ECS-DB-INITDATA -> RDS: 3306番ポート
resource "aws_security_group_rule" "rds_from_ecs_db_initdata" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = local.security_group_ids["rds"]
  source_security_group_id = local.security_group_ids["ecs-db-initdata"]
  description              = "Allow MySQL traffic from ECS DB Initdata to RDS"
}

## ECS-DB-INITUSER -> RDS: 3306番ポート
resource "aws_security_group_rule" "rds_from_ecs_db_inituser" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = local.security_group_ids["rds"]
  source_security_group_id = local.security_group_ids["ecs-db-inituser"]
  description              = "Allow MySQL traffic from ECS DB Inituser to RDS"
}