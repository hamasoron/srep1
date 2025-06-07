# 変数の定義
## 全般
variable "region_name" {
  description = "Region name."
  type = string
  validation {
    condition     = contains(["ap-northeast-1"], var.region_name)
    error_message = "region_name must be one of ap-northeast-1."
  }
}

variable "system_name" {
  description = "System name."
  type = string
  validation {
    condition     = length(var.system_name) > 0
    error_message = "system_name must not be empty."
  }
}

variable "environment_name" {
  description = "Environment name."
  type = string
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment_name)
    error_message = "environment_name must be one of prod, stg, dev."
  }
}

## Route53 Zone
variable "route53_force_destroy" {
  description = "Whether to force destroy the Route53 zone even if records exist."
  type        = bool
}

variable "caa_records" {
  description = "CAA records for the domain."
  type        = list(string)
  validation {
    condition     = length(var.caa_records) > 0
    error_message = "At least one CAA record must be specified in caa_records." ##### specify: 指定する
  }
}

## ACM
variable "subject_alternative_names" {
  description = "Subject alternative names."
  type = list(string)
  validation {
    condition     = alltrue([for v in var.subject_alternative_names : length(v) > 0])
    error_message = "All subject alternative names must not be empty."
  }
}

## VPC
variable "create_protected_ngw_associations" {
  description = "Whether to create protected subnet and NAT gateway association"
  type = bool
}

variable "nat_gateway_list" {
  description = "NAT Gateway Setting List (explicitly specify enabled/disabled for each AZ)"
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
    error_message = "az must be one of 1a, 1c, 1d."
  }
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create (0, 1, 2, 3) - for backward compatibility" ##### backward compatibility: 後方互換性
  type        = number
  default     = null
  validation {
    condition     = var.nat_gateway_count == null ? true : (var.nat_gateway_count >= 0 && var.nat_gateway_count <= 3)
    error_message = "nat_gateway_count must be between 0 and 3."
  }
}

variable "enable_auto_nat_calculation" {
  description = "Whether to automatically calculate the number of NAT Gateways based on the environment and AZ number - for backward compatibility"
  type        = bool
  default     = true
}

variable "use_all_azs_for_nat" {
  description = "Whether to configure NAT Gateways in all AZs in stg/prod environments with 3 AZs - for backward compatibility"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type = string
}

variable "map_public_ip_on_launch" {
  description = "Whether to automatically attach an Internet Gateway when launching a public subnet"
  type = bool
}

variable "subnet_list" {
  description = "List of subnets"
  type = list(object({
    name       = string
    cidr_block = string
    type       = string
  }))
  validation {
    condition = alltrue([
      for subnet in var.subnet_list : contains(["1a", "1c", "1d"], subnet.name)
    ])
    error_message = "name must be one of 1a, 1c, 1d."
  }
  validation {
    condition = alltrue([
      for subnet in var.subnet_list : contains(["public", "protected", "private"], subnet.type)
    ])
    error_message = "type must be one of public, protected, private."
  }
}

variable "route_table_list" {
  description = "List of route table"
  type = list(object({
    name         = string
    subnet       = string
    gateway_type = string
  }))
  validation {
    condition = alltrue([
      for route_table in var.route_table_list : contains(["public", "protected", "private"], route_table.name)
    ])
    error_message = "name must be one of public, protected, private."
  }
  validation {
    condition = alltrue([
      for route_table in var.route_table_list : contains(["1a", "1c", "1d"], route_table.subnet)
    ])
    error_message = "subnet must be one of 1a, 1c, 1d."
  }
  validation {
    condition = alltrue([
      for route_table in var.route_table_list : contains(["internet_gateway", "nat_gateway", "none"], route_table.gateway_type)
    ])
    error_message = "gateway_type must be one of internet_gateway, nat_gateway, none."
  }
}

## SG
variable "sg_definitions" {
  description = "Security group list"
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
  description = "GitHub repository name (owner/repository format, e.g. your-account-or-org/your-repo)"
  type        = string
  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repo)) #### 正規表現。先頭から末尾まで「スラッシュを含まない1文字以上の文字列」/「スラッシュを含まない1文字以上の文字列。
    error_message = "github_repo must be in 'owner/repository' format (your-account-or-organization/your-repo)."
  }
}

## IAM AccessAnalyzer
variable "analyzer_type" {
  description = "Type of analyzer (ACCOUNT or ORGANIZATION)"
  type        = string
  validation {
    condition     = contains(["ACCOUNT", "ORGANIZATION"], var.analyzer_type)
    error_message = "analyzer_type must be one of ACCOUNT, ORGANIZATION."
  }
}

## CloudWatch Logs
variable "rds_log_configs" {
  description = "RDS log configurations"
  type = list(object({
    name                     = string
    retention_in_days        = number
  }))
  validation {
    condition = alltrue([
      for v in var.rds_log_configs : contains(
        [
          0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365,
          400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
        ],
        v.retention_in_days
      )
    ])
    error_message = "retention_in_days must be a valid value: 0 (forever), or one of 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653."
  }
}

variable "ecs_log_configs" {
  description = "ECS log configurations"
  type        = list(object({
    name = string
    retention_in_days = number
  }))
  validation {  
    condition = alltrue([
      for v in var.ecs_log_configs : contains(
        [
          0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365,
          400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
        ],
        v.retention_in_days
      )
    ])
    error_message = "retention_in_days must be a valid value: 0 (forever), or one of 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653."
  }
}

variable "lambda_log_configs" {
  description = "Lambda log configurations"
  type = list(object({
    name                     = string
    retention_in_days        = number
  }))
  validation {
    condition = alltrue([
      for v in var.lambda_log_configs : contains(
        [
          0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365,
          400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
        ],
        v.retention_in_days
      )
    ])
    error_message = "retention_in_days must be a valid value: 0 (forever), or one of 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653."
  }
}

variable "cloudwatch_logs_kms_key_id" {
  description = "CloudWatch Logs KMS key ID"
  type        = string
  default     = null
  validation {
    condition     = var.cloudwatch_logs_kms_key_id == null || can(length(var.cloudwatch_logs_kms_key_id) > 0)
    error_message = "cloudwatch_logs_kms_key_id must be null or a non-empty string."
  }
}

## Secrets Manager
variable "recovery_window_in_days" {
  description = "Recovery window in days after deletion"
  type        = number
  validation {
    condition     = var.recovery_window_in_days >= 0
    error_message = "recovery_window_in_days must be greater than or equal to 0."
  }
}

variable "secretsmanager_kms_key_id" {
  description = "KMS key ID for SecretsManager"
  type        = string
  validation {
    condition     = var.secretsmanager_kms_key_id == null || can(length(var.secretsmanager_kms_key_id) > 0)
    error_message = "secretsmanager_kms_key_id must be null or a non-empty string."
  }
}

variable "secrets_list" {
  description = "List of secrets managed by SecretsManager"
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

variable "use_all_azs_for_aurora" {
  description = "3AZ環境で全AZにAuroraインスタンスを配置するかどうか（false=2台構成、true=3台構成）"
  type        = bool
  default     = false
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
