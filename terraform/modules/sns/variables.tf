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

## SNS
variable "create_sns_topic" {
  description = "SNSトピックを作成するかどうか"
  type        = bool
  default     = true
}

variable "topic_name" {
  description = "SNSトピック名（指定しない場合は自動生成）"
  type        = string
  default     = ""
}

variable "display_name" {
  description = "SNSトピックの表示名"
  type        = string
  default     = ""
}

variable "policy" {
  description = "SNSトピックのポリシー（JSON形式）"
  type        = string
  default     = ""
}

variable "delivery_policy" {
  description = "SNSトピックの配信ポリシー（JSON形式）"
  type        = string
  default     = ""
}

variable "application_failure_feedback_role_arn" {
  description = "アプリケーション失敗フィードバック用IAMロールARN"
  type        = string
  default     = ""
}

variable "application_success_feedback_role_arn" {
  description = "アプリケーション成功フィードバック用IAMロールARN"
  type        = string
  default     = ""
}

variable "application_success_feedback_sample_rate" {
  description = "アプリケーション成功フィードバックのサンプルレート"
  type        = number
  default     = 0
}

variable "http_failure_feedback_role_arn" {
  description = "HTTP失敗フィードバック用IAMロールARN"
  type        = string
  default     = ""
}

variable "http_success_feedback_role_arn" {
  description = "HTTP成功フィードバック用IAMロールARN"
  type        = string
  default     = ""
}

variable "http_success_feedback_sample_rate" {
  description = "HTTP成功フィードバックのサンプルレート"
  type        = number
  default     = 0
}

## 暗号化
variable "enable_encryption" {
  description = "SNS暗号化を有効にするかどうか"
  type        = bool
  default     = true
}

variable "kms_master_key_id" {
  description = "KMSキーID（指定しない場合は自動作成）"
  type        = string
  default     = ""
}

variable "create_kms_key" {
  description = "KMSキーを作成するかどうか"
  type        = bool
  default     = true
}

variable "kms_key_deletion_window_in_days" {
  description = "KMSキーの削除待機期間（日数）"
  type        = number
  default     = 7
}

variable "kms_key_description" {
  description = "KMSキーの説明"
  type        = string
  default     = "KMS key for SNS encryption"
}

## その他
variable "tags" {
  description = "リソースに適用するタグ"
  type        = map(string)
  default     = {}
} 