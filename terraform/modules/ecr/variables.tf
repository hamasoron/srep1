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
variable "enable_ecr_lifecycle_policy" {
  description = "ECRライフサイクルポリシーの有効/無効"
  type        = bool
}

variable "ecr_lifecycle_policy_count" {
  description = "ECRライフサイクルポリシーで保持するイメージ数"
  type        = number
}