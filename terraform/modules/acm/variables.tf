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

## ACM
variable "domain_name" {
  description = "ドメイン名"
  type        = string
}

variable "subject_alternative_names" {
  description = "サブドメイン名"
  type        = list(string)
}

variable "route53_zone_id" {
  description = "Route53ホストゾーンID（route53モジュールのoutputs.tfの受け皿として使用）"
  type        = string
}