# アウトプットの定義
## SG
output "sg_security_group_ids" {
  description = "Security group IDs (used by RDS, Lambda, ALB, ECS, etc.)"
  value = local.security_group_ids
}