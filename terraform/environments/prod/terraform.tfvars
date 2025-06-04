# 変数の値を定義
## 全般
region_name      = "ap-northeast-1"
system_name      = "srep1"
environment_name = "prod"

## Route53 Zone
route53_force_destroy = true
caa_records = ["0 issue \"amazon.com\""]

## ACM
subject_alternative_names = ["*.srep1.jp"]

## VPC
create_protected_ngw_associations = true
vpc_cidr                          = "10.0.0.0/19"
map_public_ip_on_launch = true
# NATゲートウェイ設定（新しいlist型）
# stg環境：2AZ時は2個、3AZ時は2個（コスト重視）または3個（高可用性）
nat_gateway_list = [
  { az = "1a", enabled = true },   # prod環境では高可用性のため最低2個配置
  { az = "1c", enabled = true },
  { az = "1d", enabled = true },   # prod環境では高可用性重視で3個配置
]
subnet_list = [
  { name = "1a", cidr_block = "10.0.0.0/24", type = "public" },
  { name = "1c", cidr_block = "10.0.1.0/24", type = "public" },
  { name = "1d", cidr_block = "10.0.2.0/24", type = "public" },
  { name = "1a", cidr_block = "10.0.3.0/24", type = "protected" },
  { name = "1c", cidr_block = "10.0.4.0/24", type = "protected" },
  { name = "1d", cidr_block = "10.0.5.0/24", type = "protected" },
  { name = "1a", cidr_block = "10.0.6.0/24", type = "private" },
  { name = "1c", cidr_block = "10.0.7.0/24", type = "private" },
  { name = "1d", cidr_block = "10.0.8.0/24", type = "private" },
]
route_table_list = [
  { name = "public", subnet = "1a", gateway_type = "internet_gateway" },
  { name = "public", subnet = "1c", gateway_type = "internet_gateway" },
  { name = "public", subnet = "1d", gateway_type = "internet_gateway" },
  { name = "protected", subnet = "1a", gateway_type = "nat_gateway" },
  { name = "protected", subnet = "1c", gateway_type = "nat_gateway" },
  { name = "protected", subnet = "1d", gateway_type = "nat_gateway" },
  { name = "private", subnet = "1a", gateway_type = "none" },
  { name = "private", subnet = "1c", gateway_type = "none" },
  { name = "private", subnet = "1d", gateway_type = "none" },
]

## SG
sg_definitions = {
  "alb" = {
    description = "ALB Security Group"
    ingress = [
      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    ]
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  }
  "ecs-front-nginx" = {
    description = "ECS Frontend Nginx Security Group"
    ingress = [{ from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = [] }]
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  }
  "ecs-api-python" = {
    description = "ECS API Python Security Group"
    ingress = [{ from_port = 8080, to_port = 8080, protocol = "tcp", cidr_blocks = [] }]
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  }
  "ecs-db-initdata" = {
    description = "ECS DB Initdata Security Group"
    ingress = []
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  }
  "ecs-db-inituser" = {
    description = "ECS DB Inituser Security Group"
    ingress = []
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  }
  "lambda" = {
    description = "Lambda Security Group"
    ingress = []
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  }
  "cloudshell" = {
    description = "CloudShell Security Group"
    ingress = []
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  }
  "rds" = {
    description = "RDS Security Group"
    ingress = [{ from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = [] }]
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  }
}

## IAM Role
github_repo = "hamasoron/srep1"

## IAM AccessAnalyzer
analyzer_type = "ACCOUNT"

## CloudWatch Logs
rds_log_configs = [
  { name = "error", retention_in_days = 1 },
  { name = "slowquery", retention_in_days = 3 },
]
ecs_log_configs = [
  { name = "front-nginx", retention_in_days = 1 },
  { name = "api-python",  retention_in_days = 3 },
  { name = "db-initdata", retention_in_days = 1 },
  { name = "db-inituser", retention_in_days = 1 }
]
lambda_log_configs = [
  { name = "master", retention_in_days = 1 },
  { name = "app", retention_in_days = 1 },
]

## Secrets Manager
recovery_window_in_days   = 0
secretsmanager_kms_key_id = null
secrets_list = [
  { name = "master", username = "root" },
  { name = "app", username = "hamasoron" },
]

## RDS
### クラスター関連
db_engine                              = "aurora-mysql"
engine_version                         = "8.0.mysql_aurora.3.05.2"
database_name                          = "hamasorondb"
backup_retention_period                = 2
preferred_backup_window                = "16:15-16:45"
skip_final_snapshot                    = true
deletion_protection                    = false
storage_encrypted                      = true
rds_kms_key_id                         = null
apply_immediately                      = false
preferred_maintenance_window_cluster   = "tue:16:45-tue:17:15"
enabled_cloudwatch_logs_exports        = ["error", "slowquery"]
copy_tags_to_snapshot                  = true
### インスタンス関連
promotion_tier                         = 1
instance_class                         = "db.t4g.medium"
preferred_maintenance_window_instanceA = "tue:17:15-tue:17:45"
auto_minor_version_upgrade             = true
enable_performance_insights            = false
monitoring_interval                    = 0

## Lambda
memory_size      = 128
timeout          = 30
reserved_concurrent_executions = null
enable_rotation_on_apply = true
rotation_secrets = ["master"] ##### 初回apply時は、appユーザーが存在しないため、masterのみローテーション
master_rotation_schedule_expression = "cron(0 18 1 * ? *)" ##### 毎月1日の深夜3時0分にマスターをローテーション
app_rotation_schedule_expression = "cron(0 19 1 * ? *)" ##### 毎月1日の深夜4時0分にアプリをローテーション（マスター完了後に実行される）
lambda_kms_key_arn = null

## S3
force_destroy       = true
log_expiration_days = 2

## ALB
### ALB関連
enable_deletion_protection       = false
enable_access_logs               = true
enable_connection_logs           = true
### ターゲットグループ関連
deregistration_delay             = 30
load_balancing_algorithm_type    = "round_robin"
### ヘルスチェック関連
health_check_interval            = 30
health_check_path                = "/"
health_check_port                = "traffic-port"
health_check_protocol            = "HTTP"
health_check_timeout             = 5
health_check_healthy_threshold   = 5
health_check_unhealthy_threshold = 2
health_check_matcher             = "200"

## CloudTrail
enable_management_logging = true   # 管理イベントは常に有効（セキュリティ上重要）
enable_data_logging = false        # データイベントは大量ログのため無効
enable_insight_logging = false     # インサイトイベントは追加コストのため無効
include_global_service_events = true
is_multi_region_trail = true
enable_log_file_validation = true
event_selector_include_management_events = true
event_selector_read_write_type = "All" ##### 読み書きのイベントを記録
exclude_management_event_sources = []

## VPC Flow Logs
enable_vpc_flow_logs = true
traffic_type = "ALL"                  # 全トラフィックを記録
max_aggregation_interval = 600        # 10分間隔（コスト効率重視）
log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${region} $${az-id}"
destination_options = {
  file_format                = "parquet" # 高圧縮・高速クエリ（Athena推奨）
  hive_compatible_partitions = true # パーティション管理をHive互換で自動化（Athena推奨）
  per_hour_partition         = false # 1時間ごとにパーティション化（Athena推奨）
}

## ECR
image_tag_mutability        = "IMMUTABLE"
ecr_force_delete            = true
encryption_type             = "AES256"
ecr_kms_key                 = null
ecr_repositories = [
  {
    name             = "front-nginx"
    description      = "フロントエンドNginx用リポジトリ"
    enable_lifecycle = true
    lifecycle_count  = 1
    scan_on_push     = true
  },
  {
    name             = "api-python"
    description      = "APIサービス用リポジトリ"
    enable_lifecycle = true
    lifecycle_count  = 2
    scan_on_push     = true
  },
  {
    name             = "db-initdata"
    description      = "初期データ投入用リポジトリ"
    enable_lifecycle = false
    lifecycle_count  = null
    scan_on_push     = false
  },
  {
    name             = "db-inituser"
    description      = "アプリケーションユーザー作成用リポジトリ"
    enable_lifecycle = false
    lifecycle_count  = null
    scan_on_push     = false
  }
]

## ECS
### クラスター関連
ecs_kms_key_id                      = null
### タスク定義関連
api_task_cpu                        = 256
api_task_memory                     = 512
front_task_cpu                      = 256
front_task_memory                   = 512
db_initdata_task_cpu                = 256
db_initdata_task_memory             = 512
db_inituser_task_cpu                = 256
db_inituser_task_memory             = 512
### サービス関連
api_desired_count                   = 0
front_desired_count                 = 0
force_new_deployment                = true
platform_version                    = "LATEST"
enable_execute_command              = true
deployment_circuit_breaker_enable   = true
deployment_circuit_breaker_rollback = true
deployment_controller_type          = "ECS"