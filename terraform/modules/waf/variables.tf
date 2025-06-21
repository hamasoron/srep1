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

variable "waf_managed_rules" {
  description = "Configuration for WAF managed rules"
  type = map(object({
    enabled         = bool
    name            = string
    priority        = number
    override_action = string
    vendor_name     = optional(string, "AWS")
    metric_name     = optional(string, null)
    excluded_rules  = optional(list(string), [])
    scope_down_statement = optional(object({
      geo_match_statement = optional(object({
        country_codes = list(string)
      }), null)
    }), null)
  }))
  validation {
    condition = alltrue([
      for rule in var.waf_managed_rules : contains(["count", "none"], rule.override_action)
    ])
    error_message = "All override_action values must be either 'count' or 'none'."
  }
}

variable "waf_rate_limit_rules" {
  description = "Configuration for WAF rate limit rules"
  type = map(object({
    name                    = string
    priority               = number
    enabled                = bool
    limit                  = number
    aggregate_key_type     = string
    action                 = string
    metric_name           = optional(string, null)
    scope_down_statement  = optional(object({
      geo_match_statement = optional(object({
        country_codes = list(string)
      }), null)
    }), null)
  }))
  default = {}
  validation {
    condition = alltrue([
      for rule in var.waf_rate_limit_rules : contains(["IP", "FORWARDED_IP"], rule.aggregate_key_type)
    ])
    error_message = "All aggregate_key_type values must be either 'IP' or 'FORWARDED_IP'."
  }
  validation {
    condition = alltrue([
      for rule in var.waf_rate_limit_rules : contains(["block", "count"], rule.action)
    ])
    error_message = "All action values must be either 'block' or 'count'."
  }
}

variable "enable_logging" {
  description = "Enable WAF logging"
  type        = bool
}

variable "redacted_headers" {
  description = "Headers to be excluded from logging"
  type        = list(string)
}