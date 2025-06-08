# アウトプットの定義
## SG
output "sg_security_group_ids" {
  description = "IDs of security groups (used by RDS, Lambda, ALB, ECS, CloudShell etc.)"
  value = local.security_group_ids
}