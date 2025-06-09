# 変数の定義
## 全般
variable "system_name" {
  description = "the system name"
  type        = string
  validation {
    condition     = length(var.system_name) > 0
    error_message = "system_name must not be empty."
  }
}

variable "environment_name" {
  description = "the environment name"
  type        = string
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment_name)
    error_message = "environment_name must be one of prod, stg, dev."
  }
}

## CloudWatch Logs
variable "rds_log_configs" {
  description = "RDS log configurations"
  type = list(object({
    name              = string
    retention_in_days = number
  }))
  validation {
    condition = alltrue([
      for v in var.rds_log_configs : contains(
        [
          0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365,
          400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
        ],
        v.retention_in_days
      )
    ])
    error_message = "retention_in_days must be a valid value: 0 (forever), or one of 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653."
  }
}


variable "ecs_log_configs" {
  description = "ECS log configurations"
  type = list(object({
    name                     = string
    retention_in_days        = number
  }))
  validation {
    condition = alltrue([
      for v in var.ecs_log_configs : contains(
        [
          0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365,
          400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
        ],
        v.retention_in_days
      )
    ])
    error_message = "retention_in_days must be a valid value: 0 (forever), or one of 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653."
  }
} 

variable "lambda_log_configs" {
  description = "Lambda log configurations"
  type = list(object({
    name                     = string
    retention_in_days        = number
  }))
  validation {
    condition = alltrue([
      for v in var.lambda_log_configs : contains(
        [
          0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365,
          400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
        ],
        v.retention_in_days
      )
    ])
    error_message = "retention_in_days must be a valid value: 0 (forever), or one of 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653."
  }
}

variable "cloudwatch_logs_kms_key_id" {
  description = "ID of KMS key for CloudWatch Logs."
  type        = string
  validation {
    condition     = var.cloudwatch_logs_kms_key_id == null || can(length(var.cloudwatch_logs_kms_key_id) > 0)
    error_message = "cloudwatch_logs_kms_key_id must be null or a non-empty string."
  }
}