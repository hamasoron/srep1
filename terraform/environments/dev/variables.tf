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

## Route53_zone
variable "route53_force_destroy" {
  description = "ゾーンを削除する際にすべてのレコードを削除するかどうか"
  type        = bool
}

## ACM
variable "domain_name" {
  description = "ドメイン名"
  type = string
}

variable "subject_alternative_names" {
  description = "サブドメイン名"
  type = list(string)
}

## VPC
variable "create_protected_ngw_associations" {
  description = "プロテクテッドサブネット及びNATゲートウェイ関連の作成有無"
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

## SecretsManager
variable "recovery_window_in_days" {
  description = "削除後の復旧ウィンドウ（日数）"
  type        = number
}

variable "secretsmanager_kms_key_id" {
  description = "シークレットマネージャーのKMSキーID"
  type        = string
}

variable "master_username" {
  description = "マスターユーザー名"
  type        = string
}

variable "master_password" {
  description = "マスターユーザーのパスワード"
  type        = string
  sensitive   = true
}

variable "app_username" {
  description = "アプリケーションユーザー名"
  type        = string
}

variable "app_password" {
  description = "アプリケーションユーザーのパスワード"
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
### ALB関連
variable "enable_deletion_protection" {
  description = "ALBの削除保護の有効/無効"
  type        = bool
}

variable "enable_access_logs" {
  description = "ALBのアクセスログを有効にするかどうか"
  type        = bool
}

variable "enable_connection_logs" {
  description = "ALBの接続ログを有効にするかどうか"
  type        = bool
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

## ECR
variable "image_tag_mutability" {
  description = "ECRイメージタグの変更可能/不可能"
  type        = string
} 

variable "scan_on_push"{
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

## CloudWatch Logs
variable "log_retention_days" {
  description = "CloudWatch Logsの保持期間（日数）"
  type        = number
}

## ECS
### クラスター関連
variable "ecs_kms_key_id" {
  description = "KMSキーID（ECSタスク定義用）"
  type        = string
}

### タスク定義関連
variable "api_task_cpu" {
  description = "APIサービスのタスクのCPU数"
  type        = number
}

variable "api_task_memory" {
  description = "APIサービスのタスクのメモリ数"
  type        = number
}

variable "front_task_cpu" {
  description = "フロントエンドサービスのタスクのCPU数"
  type        = number
}

variable "front_task_memory" {
  description = "フロントエンドサービスのタスクのメモリ数"
  type        = number
}

variable "db_initdata_task_cpu" {
  description = "データ投入用タスクのCPU数"
  type        = number
}

variable "db_initdata_task_memory" {
  description = "データ投入用タスクのメモリ数"
  type        = number
}

### サービス関連
variable "api_desired_count" {
  description = "APIサービスの希望するタスク数"
  type        = number
}

variable "front_desired_count" {
  description = "フロントエンドサービスの希望するタスク数"
  type        = number
}

variable "force_new_deployment" {
  description = "ECSサービスの強制的なデプロイを有効にするかどうか"
  type        = bool
}

variable "platform_version" {
  description = "ECSのプラットフォームバージョン"
  type        = string
}

variable "enable_execute_command" {
  description = "ECSのコマンド実行を有効にするかどうか"
  type        = bool
}

variable "deployment_circuit_breaker_enable" {
  description = "デプロイの回路遮断器を有効にするかどうか"
  type        = bool
}

variable "deployment_circuit_breaker_rollback" {
  description = "デプロイの回路遮断器をロールバックするかどうか"
  type        = bool
}

variable "deployment_controller_type" {
  description = "デプロイ制御（ECS:ローリングデプロイ、CODE_DEPLOY:ブルー/グリーンデプロイか）"
  type        = string
}