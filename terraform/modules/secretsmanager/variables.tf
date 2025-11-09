# 変数の定義
## 全般
variable "system_name" {
  description = "System name"
  type        = string
  validation {
    condition     = length(var.system_name) > 0
    error_message = "system_name must not be empty."
  }
}

variable "environment_name" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment_name)
    error_message = "environment_name must be one of prod, stg, dev."
  }
}

## Secrets Manager
variable "secrets_list" {
  description = "List of secrets managed by SecretsManager"
  type = list(object({
    name     = string
    username = string
  }))
}

variable "recovery_window_in_days" {
  description = "Recovery window in days after deletion"
  type        = number
  validation {
    condition     = var.recovery_window_in_days == 0 || (var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30)
    error_message = "recovery_window_in_days must be 0 or an integer between 7 and 30."
}
}

variable "secretsmanager_kms_key_id" {
  description = "ID of KMS key for SecretsManager"
  type        = string
  validation {
    condition     = var.secretsmanager_kms_key_id == null || can(length(var.secretsmanager_kms_key_id) > 0)
    error_message = "secretsmanager_kms_key_id must be null or a non-empty string."
  }
}
