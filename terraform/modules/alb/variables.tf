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
  description = "VPCのID（VPCモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "public_subnet_ids" {
  description = "パブリックサブネットのIDリスト（VPCモジュールのoutputs.tfの受け皿として定義）"
  type        = list(string)
}

## SG
variable "security_group_id" {
  description = "ALB用のセキュリティグループID（SGモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## ACM
variable "certificate_arn" {
  description = "HTTPSリスナーに使用するACM証明書のARN（ACMモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## S3
variable "s3_alb_logs_bucket_name" {
  description = "ALBログバケットの名前（S3モジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## ALB
### ALB関連
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

### ターゲットグループ関連
variable "deregistration_delay" {
  description = "ターゲットグループの削除遅延時間"
  type        = number
}

variable "load_balancing_algorithm_type" {
  description = "ロードバランシングアルゴリズムのタイプ"
  type        = string
}

### ヘルスチェック関連
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
