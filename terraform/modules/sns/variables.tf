# 変数の定義
## 全般
variable "system_name" {
  description = "system name"
  type        = string
  validation {
    condition     = length(var.system_name) > 0
    error_message = "system_name must not be empty."
  }
}

variable "environment_name" {
  description = "environment name"
  type        = string
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment_name)
    error_message = "environment_name must be one of prod, stg, dev."
  }
}

## SNS
variable "max_delivery_attempts" {
  description = "Maximum number of delivery attempts"
  type        = number
  validation {
    condition     = var.max_delivery_attempts >= 1 && var.max_delivery_attempts <= 10
    error_message = "max_delivery_attempts must be between 1 and 10."
  }
}