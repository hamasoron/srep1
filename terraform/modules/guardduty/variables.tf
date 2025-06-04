# # 変数の定義
# ## 全般
# variable "system_name" {
#   description = "システム名"
#   type        = string
# }

# variable "environment_name" {
#   description = "環境名"
#   type        = string
# }

# ## GuardDuty
# variable "enable_guardduty" {
#   description = "GuardDutyを有効にするかどうか"
#   type        = bool
#   default     = true
# }

# variable "enable_malware_protection" {
#   description = "マルウェア保護を有効にするかどうか"
#   type        = bool
#   default     = true
# }

# variable "enable_kubernetes_protection" {
#   description = "Kubernetes保護を有効にするかどうか"
#   type        = bool
#   default     = true
# }

# variable "enable_runtime_monitoring" {
#   description = "ランタイム監視を有効にするかどうか"
#   type        = bool
#   default     = true
# }

# variable "enable_lambda_protection" {
#   description = "Lambda保護を有効にするかどうか"
#   type        = bool
#   default     = true
# }

# variable "enable_rds_protection" {
#   description = "RDS保護を有効にするかどうか"
#   type        = bool
#   default     = true
# }

# variable "enable_s3_protection" {
#   description = "S3保護を有効にするかどうか"
#   type        = bool
#   default     = true
# }

# variable "finding_publishing_frequency" {
#   description = "検出結果の公開頻度（FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS）"
#   type        = string
#   default     = "SIX_HOURS"
#   validation {
#     condition = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency)
#     error_message = "finding_publishing_frequency must be one of: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."
#   }
# }

# variable "cloudwatch_event_rule_enabled" {
#   description = "CloudWatch Events ルールを有効にするかどうか"
#   type        = bool
#   default     = true
# }

# variable "sns_topic_arn" {
#   description = "GuardDutyアラート用のSNSトピックARN（任意）"
#   type        = string
#   default     = ""
# }

# variable "tags" {
#   description = "リソースに適用するタグ"
#   type        = map(string)
#   default     = {}
# } 