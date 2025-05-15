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
variable "deregistration_delay" {
  description = "ターゲットグループの削除遅延時間"
  type        = number
}

variable "load_balancing_algorithm_type" {
  description = "ロードバランシングアルゴリズムのタイプ"
  type        = string
}

variable "health_check_interval" {
  description = "ヘルスチェックの間隔"
  type        = number
}

variable "health_check_path" {
  description = "ヘルスチェックのパス"
  type        = string
}

variable "health_check_port" {
  description = "ヘルスチェックのポート"
  type        = string
}

variable "health_check_protocol" {
  description = "ヘルスチェックのプロトコル"
  type        = string
}

variable "health_check_timeout" {
  description = "ヘルスチェックのタイムアウト"
  type        = number
}

variable "health_check_healthy_threshold" {
  description = "ヘルスチェックの正常なしきい値"
  type        = number
}

variable "health_check_unhealthy_threshold" {
  description = "ヘルスチェックの異常なしきい値"
  type        = number
}

variable "health_check_matcher" {
  description = "ヘルスチェックのマッチャー"
  type        = string
}

## HTTPS対応
variable "certificate_arn" {
  description = "HTTPSリスナーに使用するACM証明書のARN"
  type        = string
  default     = ""
}