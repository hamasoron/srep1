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

## VPC
variable "vpc_id" {
  description = "ID of the VPC (used as a placeholder for the VPC module's outputs.tf)"
  type        = string
}

## S3
variable "s3_vpc_flow_logs_bucket_arn" {
  description = "ARN of the vpc flow logs bucket (used as a placeholder for the S3 module's outputs.tf)"
  type        = string
}

## VPC Flow Logs
variable "enable_vpc_flow_logs" {
  description = "Whether to enable VPC Flow Logs"
  type        = bool
}

variable "traffic_type" {
  description = "Traffic type to record (ALL, ACCEPT, REJECT)"
  type        = string
  validation {
    condition = contains(["ALL", "ACCEPT", "REJECT"], var.traffic_type)
    error_message = "traffic_type must be ALL, ACCEPT, or REJECT." ##### オックスフォードカンマ
  }
}

variable "max_aggregation_interval" {
  description = "Maximum aggregation interval for flow logs (60 seconds or 600 seconds)"
  type        = number
  validation {
    condition = contains([60, 600], var.max_aggregation_interval)
    error_message = "max_aggregation_interval must be 60 or 600."
  }
}

variable "log_format" {
  description = "Log format for VPC Flow Logs"
  type        = string
} 

variable "destination_options" {
  description = "Destination options for VPC Flow Logs"
  type = object({
    file_format                = string
    hive_compatible_partitions = bool
    per_hour_partition         = bool
  })
  validation {
    condition     = contains(["plain-text", "parquet"], var.destination_options.file_format)
    error_message = "destination_options.file_format must be 'plain-text' or 'parquet'."
  }
}