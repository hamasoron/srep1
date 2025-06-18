# 変数の定義
variable "system_name" {
  description = "System Name"
  type        = string
  validation {
    condition     = length(var.system_name) > 0
    error_message = "system_name must not be empty."
  }
}

variable "environment_name" {
  description = "Environment Name"
  type        = string
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment_name)
    error_message = "environment_name must be one of prod, stg, dev."
  }
}

variable "delivery_streams" {
  description = "Map of Kinesis Data Firehose delivery stream configurations"
  type = map(object({
    name        = string
    destination = string
    role_arn    = string
    bucket_arn  = string
    prefix      = string
    
    # 圧縮設定
    compression_format = optional(string, "UNCOMPRESSED")
    
    # S3バックアップ設定
    enable_s3_backup = optional(bool, false)
    
    # CloudWatch Logging設定
    enable_cloudwatch_logging = optional(bool, false)
    cloudwatch_log_group_name = optional(string)
    cloudwatch_log_stream_name = optional(string)
    
    # タグ
    tags = optional(map(string), {})
  }))
  validation {
    condition = alltrue([
      for stream in var.delivery_streams : contains(["extended_s3", "s3", "elasticsearch", "splunk", "http_endpoint", "redshift"], stream.destination)
    ])
    error_message = "destination must be one of: extended_s3, s3, elasticsearch, splunk, http_endpoint, redshift."
  }
}

variable "tags" {
  description = "リソースに付与するタグ"
  type        = map(string)
  default     = {}
} 