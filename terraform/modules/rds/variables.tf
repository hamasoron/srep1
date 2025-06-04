# 変数の定義
## 全般
variable "region_name" {
  description = "AWSリージョン"
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

## VPC
variable "private_subnet_ids" {
  description = "プライベートサブネットIDのリスト（VPCモジュールのoutputs.tfの受け皿として定義）"
  type        = list(string)
}

## SG
variable "rds_security_group_id" {
  description = "セキュリティグループID（SGモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## Secrets Manager
variable "master_username" {
  description = "マスターユーザー名（Secrets Managerモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "master_password" {
  description = "マスターユーザーのパスワード（Secrets Managerモジュールのoutputs.tfの受け皿として定義）"
  type        = string
  sensitive   = true
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

variable "rds_kms_key_id" {
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

variable "available_azs_count" {
  description = "利用可能なAZの数（VPCモジュールから取得）"
  type        = number
}

variable "available_azs_names" {
  description = "実際に使用されているAZ名のリスト（VPCモジュールから取得）"
  type        = list(string)
}

variable "cluster_instance_count" {
  description = "環境別のAuroraインスタンス数設定（明示的に指定する場合）"
  type        = number
  default     = null
}

variable "use_all_azs_for_aurora" {
  description = "3AZ環境で全AZにAuroraインスタンスを配置するかどうか（false=2台、true=3台）"
  type        = bool
  default     = true
}