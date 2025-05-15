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

## ECR
variable "image_tag_mutability" {
  description = "ECRイメージタグの変更可能/不可能"
  type        = string
}

variable "scan_on_push" {
  description = "ECRイメージの基本スキャンを有効にするかどうか"
  type        = bool
}

variable "ecr_force_delete" {
  description = "ECRリポジトリを強制的に削除するかどうか"
  type        = bool
}

variable "encryption_type" {
  description = "ECRイメージの暗号化タイプ"
  type        = string
}

variable "ecr_kms_key" {
  description = "ECRイメージの暗号化に使用するKMSキー"
  type        = string
}

variable "enable_ecr_lifecycle_policy" {
  description = "ECRライフサイクルポリシーの有効/無効"
  type        = bool
}

variable "ecr_lifecycle_policy_count" {
  description = "ECRライフサイクルポリシーで保持するイメージ数"
  type        = number
}