# 変数の定義
## 全般
variable "region_name" {
  description = "The region name."
  type = string
}

variable "system_name" {
  description = "The system name."
  type = string
}

variable "environment_name" {
  description = "The environment name."
  type = string
}

## Route53 Zone
variable "route53_force_destroy" {
  description = "Whether to force destroy the Route53 zone even if records exist."
  type        = bool
}

variable "caa_records" {
  description = "CAA records for the domain."
  type        = list(string)
}

## ACM
variable "subject_alternative_names" {
  description = "The subject alternative names."
  type = list(string)
}

## VPC
variable "create_protected_ngw_associations" {
  description = "プロテクテッドサブネット及びNATゲートウェイ関連の作成有無"
  type = bool
}

# NATゲートウェイ設定（既存のsubnet_list、route_table_listパターンに合わせたlist型）
variable "nat_gateway_list" {
  description = "NATゲートウェイの設定リスト（各AZごとの有効/無効を明示的に指定）"
  type = list(object({
    az      = string
    enabled = bool
    # 将来の拡張用（optional）
    instance_type = optional(string, "default")
    bandwidth     = optional(string, "default")
  }))
  default = [
    { az = "1a", enabled = false },
    { az = "1c", enabled = false },
    { az = "1d", enabled = false },
  ]
  validation {
    condition = alltrue([
      for ngw in var.nat_gateway_list : contains(["1a", "1c", "1d"], ngw.az)
    ])
    error_message = "azは1a、1c、1dのいずれかである必要があります。"
  }
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

variable "map_public_ip_on_launch" {
  description = "パブリックサブネットの場合、インターネットゲートウェイを起動時に自動的にアタッチするかどうか"
  type = bool
}

variable "route_table_list" {
  description = "ルートテーブルのリスト"
  type = list(object({
    name         = string
    subnet       = string
    gateway_type = string
  }))
}

## SG
variable "sg_definitions" {
  description = "セキュリティグループのリスト"
  type = map(object({
    description = string
    ingress = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
      description     = optional(string, null)
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = optional(string, null)
    }))
  }))
}

## IAM Role
variable "github_repo" {
  description = "GitHub リポジトリ名（組織名/リポジトリ名形式）"
  type        = string
}

## IAM AccessAnalyzer
variable "analyzer_type" {
  description = "アナライザーのタイプ（ACCOUNT or ORGANIZATION）"
  type        = string
}


## CloudWatch Logs
variable "rds_log_configs" {
  description = "RDSログの設定"
  type = list(object({
    name                     = string
    retention_in_days        = number
  }))
}

variable "ecs_log_configs" {
  description = "ECSログの設定"
  type        = list(object({
    name = string
    retention_in_days = number
  }))
}

variable "lambda_log_configs" {
  description = "Lambdaログの設定"
  type = list(object({
    name                     = string
    retention_in_days        = number
  }))
}

## Secrets Manager
variable "recovery_window_in_days" {
  description = "削除後の復旧ウィンドウ（日数）"
  type        = number
}

variable "secretsmanager_kms_key_id" {
  description = "シークレットマネージャーのKMSキーID"
  type        = string
}

variable "secrets_list" {
  description = "SecretsManagerで管理されたシークレットのリスト"
  type = list(object({
    name     = string
    username = string
  }))
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

## Lambda
variable "memory_size" {
  description = "Lambda関数のメモリサイズ（MB）"
  type        = number
}

variable "timeout" {
  description = "Lambda関数のタイムアウト秒数"
  type        = number
}

variable "reserved_concurrent_executions" {
  description = "Lambda関数の同時実行数"
  type        = number
}

variable "enable_rotation_on_apply" {
  description = "初回terraform apply時にローテーションを有効にするかどうか（false=コンソールから手動でローテーション実行）"
  type        = bool
}

variable "rotation_secrets" {
  description = "ローテーション対象のシークレットの名前"
  type        = list(string)
}

variable "master_rotation_schedule_expression" {
  description = "マスターローテーションのスケジュール（cron式）"
  type        = string
}

variable "app_rotation_schedule_expression" {
  description = "アプリローテーションのスケジュール（cron式）"
  type        = string
}

variable "lambda_kms_key_arn" {
  description = "Lambda関数で使用するKMSキーのARN"
  type        = string
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

## CloudTrail
variable "enable_management_logging" {
  description = "管理イベント証跡のログ記録を有効にするかどうか（セキュリティ・コンプライアンス上重要）"
  type        = bool
}

variable "enable_data_logging" {
  description = "データイベント証跡のログ記録を有効にするかどうか（大量ログ発生のため注意）"
  type        = bool
}

variable "enable_insight_logging" {
  description = "インサイトイベント証跡のログ記録を有効にするかどうか（追加コスト発生）"
  type        = bool
}

variable "include_global_service_events" {
  description = "グローバルサービスイベントを含めるかどうか"
  type        = bool
}

variable "is_multi_region_trail" {
  description = "マルチリージョントレイルにするかどうか"
  type        = bool
}

variable "enable_log_file_validation" {
  description = "ログファイル検証を有効にするかどうか"
  type        = bool
}

variable "event_selector_include_management_events" {
  description = "管理イベントを含めるかどうか"
  type        = bool
}

variable "event_selector_read_write_type" {
  description = "読み書きのイベントを記録するかどうか"
  type        = string
}

variable "exclude_management_event_sources" {
  description = "管理イベントに含めないイベントソース"
  type        = list(string)
}

## VPC Flow Logs
variable "enable_vpc_flow_logs" {
  description = "VPC Flow Logsを有効にするかどうか"
  type        = bool
}

variable "traffic_type" {
  description = "記録するトラフィック（ALL, ACCEPT, REJECT）"
  type        = string
}

variable "max_aggregation_interval" {
  description = "フローログの最大集約間隔（60秒または600秒）"
  type        = number
}

variable "log_format" {
  description = "VPC Flow Logsのログフォーマット"
  type        = string
}

variable "destination_options" {
  description = "VPC Flow Logsの宛先オプション"
  type = object({
    file_format                = string
    hive_compatible_partitions = bool
    per_hour_partition         = bool
  })
}

## ECR
variable "image_tag_mutability" {
  description = "ECRイメージタグの変更可能/不可能"
  type        = string
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

variable "ecr_repositories" {
  description = "ECRリポジトリごとの設定"
  type = list(object({
    name             = string
    description      = string
    enable_lifecycle = optional(bool)
    lifecycle_count  = optional(number)
    scan_on_push     = optional(bool)
  }))
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

variable "db_inituser_task_cpu" {
  description = "ユーザー作成用タスクのCPU数"
  type        = number
}

variable "db_inituser_task_memory" {
  description = "ユーザー作成用タスクのメモリ数"
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