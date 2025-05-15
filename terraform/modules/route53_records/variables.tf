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

## Route53_zone
variable "route53_zone_id" {
  description = "Route53のゾーンID"
  type        = string
}

## Route53_records
variable "alb_dns_name" {
  description = "ALBのDNS名"
  type        = string
}

variable "alb_zone_id" {
  description = "ALBのゾーンID"
  type        = string
}
