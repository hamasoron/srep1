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

## secretsmanager
variable "recovery_window_in_days" {
  description = "削除後の復旧ウィンドウ（日数）"
  type        = number
}

variable "secretsmanager_kms_key_id" {
  description = "SecretsManagerのKMSキーID"
  type        = string
}

## RDS（Aurora）マスターユーザー
variable "master_username" {
  description = "マスターユーザー名"
  type        = string
}

variable "master_password" {
  description = "マスターユーザーのパスワード"
  type        = string
  sensitive   = true
}

## RDS（Aurora）アプリケーションユーザー
variable "app_username" {
  description = "アプリケーションユーザー名"
  type        = string
}

variable "app_password" {
  description = "アプリケーションユーザーのパスワード"
  type        = string
  sensitive   = true
}
