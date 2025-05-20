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
variable "route53_zone_id" {
  description = "Route53のゾーンID（Route53 Zoneモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## Route53 Records
variable "alb_dns_name" {
  description = "ALBのDNS名（ALBモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "alb_zone_id" {
  description = "ALBのゾーンID（ALBモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}