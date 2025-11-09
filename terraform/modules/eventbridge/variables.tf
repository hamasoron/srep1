# 変数の定義
## 全般
variable "system_name" {
  description = "system name"
  type        = string
  validation {
    condition     = length(var.system_name) > 0
    error_message = "system_name must not be empty."
  }
}

variable "environment_name" {
  description = "environment name"
  type        = string
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment_name)
    error_message = "environment_name must be one of prod, stg, dev."
  }
}

## EventBridge
### ルールの設定
variable "event_rule_state" {
  description = "state of eventBridge rule"
  type        = string
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.event_rule_state)
    error_message = "event_rule_state must be either ENABLED or DISABLED."
  }
}

variable "severity_level" {
  description = "Minimum severity level to filter GuardDuty findings. Choose from: low (1.0+), medium (4.0+), high (7.0+), critical (9.0+)"
  type        = string 
  validation {
    condition     = contains(["low", "medium", "high", "critical"], var.severity_level) ##### severity: 重要度
    error_message = "severity_level must be one of: low, medium, high, critical. Corresponds to GuardDuty severity ranges: Low (1.0-3.9), Medium (4.0-6.9), High (7.0-8.9), Critical (9.0-10.0)."
  }
}

## ターゲットの設定
variable "sns_guardduty_topic_arn" {
  description = "ARN of SNS topic to send GuardDuty findings"
  type        = string
  validation {
    condition     = length(var.sns_guardduty_topic_arn) > 0
    error_message = "sns_guardduty_topic_arn must not be empty."
  }
}