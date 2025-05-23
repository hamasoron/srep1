# 変数の定義
## 全般
variable "region_name" {
  description = "リージョン名"
  type        = string
}

variable "system_name" {
  description = "システム名"
  type        = string
}

variable "environment_name" {
  description = "環境名"
  type        = string
}

## Secrets Manager
variable "recovery_window_in_days" {
  description = "削除後の復旧ウィンドウ（日数）"
  type        = number
}

variable "secretsmanager_kms_key_id" {
  description = "SecretsManagerのKMSキーID"
  type        = string
}

variable "secrets" {
  description = "シークレット情報のリスト"
  type = list(object({
    name     = string
    username = string
  }))
}