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

## VPC
variable "vpc_id" {
  description = "VPCのID（VPCモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## S3
variable "s3_vpc_flow_logs_bucket_arn" {
  description = "ARN of the vpc flow logs bucket (used as a placeholder for the S3 module's outputs.tf)"
  type        = string
}

## VPC Flow Logs
variable "enable_vpc_flow_logs" {
  description = "VPC Flow Logsを有効にするかどうか"
  type        = bool
}

variable "traffic_type" {
  description = "記録するトラフィック（ALL, ACCEPT, REJECT）"
  type        = string
  validation {
    condition = contains(["ALL", "ACCEPT", "REJECT"], var.traffic_type)
    error_message = "traffic_type must be ALL, ACCEPT, or REJECT." ##### オックスフォードカンマ
  }
}

variable "max_aggregation_interval" {
  description = "フローログの最大集約間隔（60秒または600秒）"
  type        = number
  validation {
    condition = contains([60, 600], var.max_aggregation_interval)
    error_message = "max_aggregation_interval must be 60 or 600."
  }
}

variable "log_format" {
  description = "VPC Flow Logsのログフォーマット"
  type        = string
} 

variable "destination_options" {
  description = "VPC Flow Logsの宛先オプション"
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