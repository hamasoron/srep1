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

## S3
variable "s3_cloudtrail_logs_bucket_name" {
  description = "S3 bucket name for CloudTrail logs (used as a placeholder for the S3 module's outputs.tf)"
  type        = string
}

## CloudTrail
variable "enable_management_logging" {
  description = "Whether to enable management event logging"
  type        = bool
}

variable "cloudtrail_kms_key_id" {
  description = "ID of the KMS key for CloudTrail logs"
  type        = string
  validation {
    condition     = var.cloudtrail_kms_key_id == null || can(length(var.cloudtrail_kms_key_id) > 0)
    error_message = "cloudtrail_kms_key_id must be null or a non-empty string."
  }
}

variable "include_global_service_events" {
  description = "Whether to include global service events"
  type        = bool
}

variable "is_multi_region_trail" {
  description = "Whether to enable multi-region trail"
  type        = bool
}

variable "enable_log_file_validation" {
  description = "Whether to enable log file validation"
  type        = bool
}

variable "event_selector_include_management_events" {
  description = "Whether to include management events"
  type        = bool
}

variable "event_selector_read_write_type" {
  description = "Whether to record read/write events"
  type        = string
  validation {
    condition     = contains(["All", "ReadOnly", "WriteOnly"], var.event_selector_read_write_type)
    error_message = "event_selector_read_write_type must be one of All, ReadOnly, WriteOnly."
  }
}

variable "exclude_management_event_sources" {
  description = "Event sources to exclude from management events"
  type        = list(string)
}

variable "enable_data_logging" {
  description = "Whether to enable data event logging"
  type        = bool
}

variable "enable_insight_logging" {
  description = "Whether to enable insight event logging"
  type        = bool
}
