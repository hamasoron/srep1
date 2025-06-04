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

## Route53
variable "route53_force_destroy" {
  description = "Whether to force destroy the Route53 zone even if records exist."
  type        = bool
}

variable "caa_records" {
  description = "CAA records for the domain."
  type        = list(string)
  validation {
    condition     = length(var.caa_records) > 0
    error_message = "At least one CAA record must be specified in caa_records." ##### specify: 指定する
  }
}