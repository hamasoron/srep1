variable "system_name" {
  description = "システム名"
  type        = string
}

variable "environment_name" {
  description = "環境名（dev, stg, prod など）"
  type        = string
}

variable "region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "engine_version" {
  description = "Aurora MySQLのエンジンバージョン"
  type        = string
  default     = "8.0"
}

variable "database_name" {
  description = "データベース名"
  type        = string
}

variable "master_username" {
  description = "マスターユーザー名"
  type        = string
}

variable "master_password" {
  description = "マスターパスワード"
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
  description = "バックアップの保持期間（日）"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "バックアップウィンドウ（UTCの時間形式）"
  type        = string
  default     = "19:00-20:00"  # JST: 04:00-05:00
}

variable "security_group_id" {
  description = "RDSセキュリティグループID"
  type        = string
}

variable "subnet_ids" {
  description = "サブネットIDのリスト"
  type        = list(string)
}

variable "instance_class" {
  description = "RDSインスタンスクラス"
  type        = string
  default     = "db.t3.medium"
}

variable "skip_final_snapshot" {
  description = "削除時に最終スナップショットを取得しない場合はtrue"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "削除保護の有効化"
  type        = bool
  default     = true
}

variable "storage_encrypted" {
  description = "ストレージの暗号化"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMSキーID（ストレージ暗号化用）"
  type        = string
  default     = null
} 