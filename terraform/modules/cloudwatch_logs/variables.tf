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
variable "rds_log_configs" {
  description = "RDSログの設定"
  type = list(object({
    name                     = string
    retention_in_days        = number
  }))
}

variable "ecs_log_configs" {
  description = "ECSログの設定"
  type = list(object({
    name                     = string
    retention_in_days        = number
  }))
} 

variable "lambda_log_configs" {
  description = "Lambdaログの設定"
  type = list(object({
    name                     = string
    retention_in_days        = number
  }))
}
