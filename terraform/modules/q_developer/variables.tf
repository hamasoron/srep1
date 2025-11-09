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

## IAM Role
variable "iam_role_arn" {
  description = "ARN of the IAM role for Amazon Q Developer（used as a placeholder for the IAM Role module's outputs.tf）"
  type        = string
  }

## SNS
variable "sns_topic_arn" {
  description = "ARN of the SNS topic（used as a placeholder for the SNS module's outputs.tf）"
  type        = string
}

## Amazon Q Developer
variable "slack_channel_id" {
  description = "Slack channel ID for notifications"
  type        = string
}

variable "slack_team_id" {
  description = "Slack team (workspace) ID"
  type        = string
}

variable "logging_level" {
  description = "Logging level for Amazon Q Developer"
  type        = string
}

variable "user_authorization_required" {
  description = "Whether user authorization is required for Amazon Q Developer features"
  type        = bool
} 