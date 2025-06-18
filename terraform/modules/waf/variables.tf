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
    error_message = "override_action must be one of count or none." ##### count: カウント（開発、検証環境）、none: ルールごとのデフォルト（本番環境）
  }
}

variable "firehose_role_arn" {
  description = "ARN of the Kinesis Firehose role for WAF logging"
  type        = string
  default     = null
}

variable "firehose_delivery_stream_arn" {
  description = "ARN of the Kinesis Firehose delivery stream for WAF logging"
  type        = string
  default     = null
}

variable "tags" {
  description = "リソースに付与するタグ"  
  type        = map(string)
  default     = {}
}

variable "enable_logging" {
  description = "WAFログの有効化"
  type        = bool
}

variable "redacted_headers" {
  description = "ログから除外するヘッダー"
  type        = list(string)
  default     = ["authorization", "cookie", "x-forwarded-for"]
}

variable "enable_rate_limit" {
  description = "レート制限の有効化"
  type        = bool
  default     = true
}

variable "rate_limit_requests_per_5_minutes" {
  description = "5分間あたりのリクエスト制限数"
  type        = number
  default     = 1000
} 