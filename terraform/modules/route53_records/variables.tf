# 変数の定義
## 全般
variable "system_name" {
  description = "System name."
  type        = string
  validation {
    condition     = length(var.system_name) > 0
    error_message = "system_name must not be empty."
  }
}

variable "environment_name" {
  description = "Environment name."
  type        = string
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment_name)
    error_message = "environment_name must be one of prod, stg, dev."
  }
}

## Route53 Zone
variable "route53_zone_id" {
  description = "Route53 zone ID (used as a placeholder for the Route53 Zone module's outputs.tf)"
  type        = string
}

## Route53 Records
variable "alb_dns_name" {
  description = "ALB DNS name (used as a placeholder for the ALB module's outputs.tf)"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB zone ID (used as a placeholder for the ALB module's outputs.tf)"
  type        = string
}