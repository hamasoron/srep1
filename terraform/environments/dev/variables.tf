# 変数の定義
## 全般
variable "region_name" {
  description = "リージョン名"
  type = string
}

variable "system_name" {
  description = "システム名"
  type = string
}

variable "environment_name" {
  description = "環境名"
  type = string
}

## VPC
variable "create_protected_ngw_associations" {
  description = "保護された及びNATゲートウェイ関連の作成有無"
  type = bool
}

variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type = string
}

variable "subnet_list" {
  description = "サブネットのリスト"
  type = list(object({
    name       = string
    cidr_block = string
    type       = string
  }))
}

variable "route_table_list" {
  description = "ルートテーブルのリスト"
  type = list(object({
    name         = string
    subnet       = string
    gateway_type = string
  }))
}

## セキュリティグループ
variable "sg_definitions" {
  description = "セキュリティグループのリスト"
  type = map(object({
    description = string
    ingress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
}

## IAMロール
variable "github_repo" {
  description = "GitHub リポジトリ名（組織名/リポジトリ名形式）"
  type        = string
}

## RDS
### クラスター関連
variable "db_engine" {
  description = "データベースエンジン"
  type        = string
}

variable "engine_version" {
  description = "データベースエンジンのバージョン"
  type        = string
}

variable "database_name" {
  description = "データベース名"
  type        = string
}

variable "master_username" {
  description = "RDSのマスターユーザー名"
  type        = string
}

variable "master_password" {
  description = "RDSのマスターパスワード"
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
  description = "バックアップの保持期間（日）"
  type        = number
}

variable "preferred_backup_window" {
  description = "バックアップの実行時間帯（UTC）"
  type        = string
}

variable "skip_final_snapshot" {
  description = "削除時にファイナルスナップショットを作成するかどうか"
  type        = bool
}

variable "deletion_protection" {
  description = "終了保護の有効/無効"
  type        = bool
}

variable "storage_encrypted" {
  description = "ストレージの暗号化"
  type        = bool
}

variable "kms_key_id" {
  description = "KMSキーID（ストレージ暗号化用）"
  type        = string
}

variable "apply_immediately" {
  description = "即時適用かメンテナンスウィンドウ時に適用か（パラメータの更新時）"
  type        = bool
}

variable "preferred_maintenance_window_cluster" {
  description = "クラスターのメンテナンスウィンドウの実行時間帯（UTC）"
  type        = string
}

variable "enabled_cloudwatch_logs_exports" {
  description = "CloudWatch Logsのエクスポート"
  type        = list(string)
}

variable "copy_tags_to_snapshot" {
  description = "スナップショットにタグをコピーするかどうか"
  type        = bool
}

### インスタンス関連
variable "promotion_tier" {
  description = "フェイルオーバー時の昇格階層"
  type        = number
}

variable "instance_class" {
  description = "RDSインスタンスクラス"
  type        = string
}

variable "preferred_maintenance_window_instanceA" {
  description = "インスタンスAのメンテナンスウィンドウの実行時間帯（UTC）"
  type        = string
}

variable "auto_minor_version_upgrade" {
  description = "マイナーバージョンの自動アップグレード"
  type        = bool
}

variable "enable_performance_insights" {
  description = "パフォーマンスインサイトの有効/無効"
  type        = bool
}

variable "monitoring_interval" {
  description = "モニタリング間隔"
  type        = number
}

## S3
variable "force_destroy" {
  description = "S3バケットを強制的に削除するかどうか"
  type        = bool
}

variable "log_expiration_days" {
  description = "ログの保存期間（日）"
  type        = number
}

## ALB
variable "enable_deletion_protection" {
  description = "ALBの削除保護の有効/無効"
  type        = bool
}

variable "deregistration_delay" {
  description = "ターゲットグループの削除遅延時間"
  type        = number
}

variable "enable_access_logs" {
  description = "ALBのアクセスログを有効にするかどうか"
  type        = bool
}

variable "enable_connection_logs" {
  description = "ALBの接続ログを有効にするかどうか"
  type        = bool
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

## ECS
variable "api_desired_count" {
  description = "APIサービスのタスク数"
  type        = number
  default     = 0
}

variable "front_desired_count" {
  description = "フロントエンドサービスのタスク数"
  type        = number
  default     = 0
}
