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
variable "domain_name" {
  description = "Domain name (used as a placeholder for the route53_zone module's outputs.tf)." ##### placeholder: 代理値
  type        = string
  validation {
    condition     = length(var.domain_name) > 0
    error_message = "domain_name must not be empty."
  }
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID (used as a placeholder for the route53_zone module's outputs.tf)."
  type        = string
  validation {
    condition     = length(var.route53_zone_id) > 0
    error_message = "route53_zone_id must not be empty."
  }
}

## ACM
variable "subject_alternative_names" {
  description = "Subject alternative names."
  type        = list(string)
  validation {
    condition     = alltrue([for v in var.subject_alternative_names : length(v) > 0])
    error_message = "All subject alternative names must not be empty."
  }
}