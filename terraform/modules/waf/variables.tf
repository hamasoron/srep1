# 変数の定義
## 全般
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

## S3
variable "s3_waf_logs_bucket_arn" {
  description = "ARN of the S3 bucket for WAF logs"
  type        = string
}

## ALB
variable "alb_arn" {
  description = "ARN of the ALB"
  type        = string
} 

## WAF
variable "scope" {
  description = "Scope to attach WAF"
  type        = string
  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "scope must be one of REGIONAL or CLOUDFRONT." ##### アタッチ先がリージョンサービスかCloudFrontか
  }
}

variable "override_action" {
  description = "Override action"
  type        = string
  validation {
    condition     = contains(["count", "none"], var.override_action)
    error_message = "override_action must be one of count or none." ##### count: カウントアクションに上書き（開発、検証環境）、none: 各ルールごとのデフォルトのアクションを使用（本番環境）
  }
}

variable "enable_rate_limit" {
  description = "Enable rate limiting"
  type        = bool
}

variable "rate_limit_requests_per_5_minutes" {
  description = "Number of requests per 5 minutes"
  type        = number
}

variable "enable_logging" {
  description = "Enable WAF logging"
  type        = bool
}

variable "redacted_headers" {
  description = "Headers to be excluded from logging"
  type        = list(string)
}