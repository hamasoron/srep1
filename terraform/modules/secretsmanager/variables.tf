# 変数の定義
## 全般
variable "system_name" {
  description = "The system name"
  type        = string
  validation {
    condition     = length(var.system_name) > 0
    error_message = "system_name must not be empty."
  }
}

variable "environment_name" {
  description = "The environment name"
  type        = string
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment_name)
    error_message = "environment_name must be one of prod, stg, dev."
  }
}

## Secrets Manager
variable "recovery_window_in_days" {
  description = "The recovery window in days after deletion"
  type        = number
  validation {
    condition     = var.recovery_window_in_days >= 0
    error_message = "recovery_window_in_days must be greater than or equal to 0."
  }
}

variable "secretsmanager_kms_key_id" {
  description = "The KMS key ID for SecretsManager"
  type        = string
  validation {
    condition     = var.secretsmanager_kms_key_id == null || can(length(var.secretsmanager_kms_key_id) > 0)
    error_message = "secretsmanager_kms_key_id must be null or a non-empty string."
  }
}

variable "secrets_list" {
  description = "The list of secrets managed by SecretsManager"
  type = list(object({
    name     = string
    username = string
  }))
}