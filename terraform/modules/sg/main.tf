#　リソースの定義
## SGの作成 - 基本セキュリティグループ
resource "aws_security_group" "terra_security_group" {
  for_each    = var.sg_definitions
  name        = "${var.system_name}-${var.environment_name}-${each.key}-sg"
  description = each.value.description
  vpc_id      = var.vpc_id

  ## CIDRブロックのみを指定するインバウンドルール（セキュリティグループへの参照を含まないルール）
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

  ## 通常のアウトバウンドルール
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

  # セキュリティグループ間の依存関係がないことを明示
  lifecycle {
    create_before_destroy = true
  }
}

# セキュリティグループIDを参照するためのローカル変数
locals {
  security_group_ids = {
    for k, v in aws_security_group.terra_security_group : k => v.id
  }
}

# ECS -> ALB: 80番ポート
resource "aws_security_group_rule" "ecs_from_alb_80" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = local.security_group_ids["ecs"]
  source_security_group_id = local.security_group_ids["alb"]
  description              = "Allow HTTP traffic from ALB to ECS"
}

# ECS -> ALB: 443番ポート
resource "aws_security_group_rule" "ecs_from_alb_443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = local.security_group_ids["ecs"]
  source_security_group_id = local.security_group_ids["alb"]
  description              = "Allow HTTPS traffic from ALB to ECS"
}

# RDS -> ECS: 3306番ポート
resource "aws_security_group_rule" "rds_from_ecs" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = local.security_group_ids["rds"]
  source_security_group_id = local.security_group_ids["ecs"]
  description              = "Allow MySQL traffic from ECS to RDS"
}

# RDS -> EC2: 3306番ポート
resource "aws_security_group_rule" "rds_from_ec2" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = local.security_group_ids["rds"]
  source_security_group_id = local.security_group_ids["ec2"]
  description              = "Allow MySQL traffic from EC2 to RDS"
}
