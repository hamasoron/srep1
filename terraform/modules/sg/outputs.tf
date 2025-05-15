# アウトプットの定義
## セキュリティグループ
output "security_group_ids" {
  description = "セキュリティグループのID（RDSやALBやECSモジュール等で使用）"
  value = local.security_group_ids
}