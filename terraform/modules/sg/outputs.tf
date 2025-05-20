# アウトプットの定義
## SG
output "sg_security_group_ids" {
  description = "セキュリティグループのID（RDSやALBやECSモジュール等で使用）"
  value = local.security_group_ids
}