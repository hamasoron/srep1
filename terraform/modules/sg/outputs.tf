# アウトプットの定義
## セキュリティグループ
output "security_group_ids" {
  description = "セキュリティグループのID"
  value = local.security_group_ids
}