# 変数の定義
## 全般
variable "system_name" {
  description = "システム名"
  type        = string
}

variable "environment_name" {
  description = "環境名"
  type        = string
}

## Route53
variable "route53_force_destroy" {
  description = "レコードがある場合にゾーンを強制的に削除するかどうか"
  type        = bool
}
