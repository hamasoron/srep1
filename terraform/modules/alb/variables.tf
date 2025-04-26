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

## VPC
variable "vpc_id" {
  description = "VPCのID"
  type        = string
}

variable "public_subnet_ids" {
  description = "パブリックサブネットのIDリスト"
  type        = list(string)
}

variable "protected_subnet_ids" {
  description = "保護されたサブネットのIDリスト"
  type        = list(string)
}

variable "create_protected_ngw_associations" {
  description = "保護された及びNATゲートウェイ関連の作成有無"
  type        = bool
}

## セキュリティグループ
variable "security_group_id" {
  description = "ALB用のセキュリティグループID"
  type        = string
}

## ALB
variable "enable_deletion_protection" {
  description = "ALBの削除保護を有効にするかどうか"
  type        = bool
}

variable "deregistration_delay" {
  description = "ターゲットグループの削除遅延時間"
  type        = number
}

variable "enable_access_logs" {
  description = "ALBのアクセスログを有効にするかどうか"
  type        = bool
  default     = false
}

variable "enable_connection_logs" {
  description = "ALBの接続ログを有効にするかどうか"
  type        = bool
  default     = false
}