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

## EventBridge
variable "enable_eventbridge" {
  description = "EventBridgeを有効にするかどうか"
  type        = bool
  default     = true
}

variable "rule_name" {
  description = "EventBridgeルール名（指定しない場合は自動生成）"
  type        = string
  default     = ""
}

variable "rule_description" {
  description = "EventBridgeルールの説明"
  type        = string
  default     = "EventBridge rule for processing events"
}

variable "event_pattern" {
  description = "イベントパターン（JSON形式）"
  type        = string
}

variable "targets" {
  description = "EventBridgeターゲットの設定"
  type = list(object({
    target_id = string
    arn       = string
    input     = optional(string)
    input_transformer = optional(object({
      input_paths_map = map(string)
      input_template  = string
    }))
  }))
  default = []
}

variable "schedule_expression" {
  description = "スケジュール式（cron or rate）"
  type        = string
  default     = ""
}

variable "state" {
  description = "ルールの状態（ENABLED or DISABLED）"
  type        = string
  default     = "ENABLED"
  validation {
    condition = contains(["ENABLED", "DISABLED"], var.state)
    error_message = "state must be either ENABLED or DISABLED."
  }
}

variable "tags" {
  description = "リソースに適用するタグ"
  type        = map(string)
  default     = {}
} 