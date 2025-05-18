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

## Route53 Zone
variable "domain_name" {
  description = "ドメイン名（route53_zoneモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53ホストゾーンID（route53_zoneモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## ACM
variable "subject_alternative_names" {
  description = "サブドメイン名"
  type        = list(string)
}
