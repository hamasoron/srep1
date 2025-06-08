#　リソースの定義
## セキュリティグループの作成 - 基本セキュリティグループ
resource "aws_security_group" "terra_security_group" {
  for_each    = var.sg_definitions
  name        = "${var.system_name}-${var.environment_name}-${each.key}-sg"
  description = each.value.description
  vpc_id      = var.vpc_id
  ## インバウンドルール（cidr_blocksキーがあるルールのみ。security_groupsキーがあるルールは対象外）
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
  # security_groupsフィールドを使用するingressルールをフラット化
  sg_ingress_rules = flatten([
    for sg_key, sg_config in var.sg_definitions : [
      for rule in sg_config.ingress : [
        for source_sg in lookup(rule, "security_groups", []) : {
          sg_key      = sg_key
          from_port   = rule.from_port
          to_port     = rule.to_port
          protocol    = rule.protocol
          source_sg   = source_sg
          description = lookup(rule, "description", null)
        }
      ]
      if length(lookup(rule, "security_groups", [])) > 0
    ]
  ])
}

## Security Group間の参照ルール
resource "aws_security_group_rule" "sg_ingress_rules" {
  for_each = {
    for rule in local.sg_ingress_rules : "${rule.sg_key}-${rule.source_sg}-${rule.from_port}-${rule.to_port}" => rule
  }
  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  security_group_id        = local.security_group_ids[each.value.sg_key]
  source_security_group_id = local.security_group_ids[each.value.source_sg]
  description              = each.value.description
}