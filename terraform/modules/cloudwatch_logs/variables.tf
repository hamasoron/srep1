# 変数の定義
## 全般
variable "system_name" {
  description = "システム名"
  type        = string
}

variable "environment_name" {
  description = "環境名（prod, stg, dev）"
  type        = string
}

## CloudWatch Logs
variable "log_retention_days" {
  description = "CloudWatch Logsの保持期間（日数）"
  type        = number
}

variable "services" {
  description = "設定するサービス一覧"
  type = list(object({
    name                     = string
  }))
} 