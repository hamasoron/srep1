# variable "system_name" {
#   description = "システム名"
#   type        = string
# }

# variable "environment_name" {
#   description = "環境名"
#   type        = string
# }

# variable "tags" {
#   description = "リソースに付与するタグ"
#   type        = map(string)
#   default     = {}
# }

# variable "enable_logging" {
#   description = "WAFログの有効化"
#   type        = bool
#   default     = true
# }

# variable "log_retention_days" {
#   description = "WAFログの保持日数"
#   type        = number
#   default     = 30
# }

# variable "redacted_headers" {
#   description = "ログから除外するヘッダー"
#   type        = list(string)
#   default     = ["authorization", "cookie", "x-forwarded-for"]
# }

# variable "enable_rate_limit" {
#   description = "レート制限の有効化"
#   type        = bool
#   default     = true
# }

# variable "rate_limit_requests_per_5_minutes" {
#   description = "5分間あたりのリクエスト制限数"
#   type        = number
#   default     = 2000
# } 