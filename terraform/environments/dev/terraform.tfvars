# 変数の値を定義
## 全般
region_name      = "ap-northeast-1"
system_name      = "srep1"
environment_name = "dev"

## Route53 Zone
route53_force_destroy = true
caa_records = ["0 issue \"amazon.com\""]

## ACM
subject_alternative_names = ["*.srep1.jp"]

## VPC
create_protected_ngw_associations = true ### protected及びnat_gatewayを使用するか否か
vpc_cidr                          = "10.0.64.0/19"
map_public_ip_on_launch = true
nat_gateway_list = [
  { az = "1a", enabled = true }, ### dev環境：protectedがある時1個（1a）、ない時0個が推奨
  { az = "1c", enabled = false },
  { az = "1d", enabled = false },
]
subnet_list = [
  { name = "1a", cidr_block = "10.0.64.0/24", type = "public" }, ### create_protected_ngw_associationsとnat_gateway_listに合わせて設定
  { name = "1c", cidr_block = "10.0.65.0/24", type = "public" },
  { name = "1d", cidr_block = "10.0.66.0/24", type = "public" },
  { name = "1a", cidr_block = "10.0.67.0/24", type = "protected" },
  { name = "1c", cidr_block = "10.0.68.0/24", type = "protected" },
  { name = "1d", cidr_block = "10.0.69.0/24", type = "protected" },
  { name = "1a", cidr_block = "10.0.70.0/24", type = "private" },
  { name = "1c", cidr_block = "10.0.71.0/24", type = "private" },
  { name = "1d", cidr_block = "10.0.72.0/24", type = "private" },
]
route_table_list = [
  { name = "public", subnet = "1a", gateway_type = "internet_gateway" }, ### create_protected_ngw_associationsとnat_gateway_listに合わせて設定
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
      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTP from internet" },
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTPS from internet" },
    ]
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], description = "All outbound traffic" }]
  }
  "ecs-front-nginx" = {
    description = "ECS Frontend Nginx Security Group"
    ingress = [{ from_port = 80, to_port = 80, protocol = "tcp", security_groups = ["alb"], description = "HTTP from ALB" }]
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], description = "All outbound traffic" }]
  }
  "ecs-api-python" = {
    description = "ECS API Python Security Group"
    ingress = [{ from_port = 8080, to_port = 8080, protocol = "tcp", security_groups = ["ecs-front-nginx"], description = "API access from frontend" }]
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], description = "All outbound traffic" }]
  }
  "ecs-db-initdata" = {
    description = "ECS DB Initdata Security Group"
    ingress = []
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], description = "All outbound traffic" }]
  }
  "ecs-db-inituser" = {
    description = "ECS DB Inituser Security Group"
    ingress = []
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], description = "All outbound traffic" }]
  }
  "lambda" = {
    description = "Lambda Security Group"
    ingress = []
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], description = "All outbound traffic" }]
  }
  "cloudshell" = {
    description = "CloudShell Security Group"
    ingress = []
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], description = "All outbound traffic" }]
  }
  "rds" = {
    description = "RDS Security Group"
    ingress = [{ from_port = 3306, to_port = 3306, protocol = "tcp", security_groups = ["ecs-api-python", "ecs-db-initdata", "ecs-db-inituser", "lambda", "cloudshell"], description = "MySQL access from application services" }]
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], description = "All outbound traffic" }]
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
cloudwatch_logs_kms_key_id = null

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
engine_version                         = "8.0.mysql_aurora.3.08.2"
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
performance_insights_enabled           = false
performance_insights_retention_period  = 7
performance_insights_kms_key_id        = null
monitoring_interval                    = 0
monitoring_role_arn                    = null
copy_tags_to_snapshot                  = true
### インスタンス関連
instance_class                         = "db.t4g.medium"
auto_minor_version_upgrade             = true
preferred_maintenance_window_base      = "tue:17:15-tue:17:45"
publicly_accessible                    = false
deployment_mode                        = "writer_only" ##### writer_only, writer_with_1_reader, writer_with_2_readers

## Lambda
memory_size      = 128
timeout          = 30
reserved_concurrent_executions = null
enable_rotation_on_apply = true
rotation_secrets = ["master", "app"] ##### 初回apply時は、appユーザーが存在しないため、masterのみローテーション
master_rotation_schedule_expression = "cron(0 18 1 * ? *)" ##### 毎月1日の深夜3時0分にマスターをローテーション
app_rotation_schedule_expression = "cron(0 19 1 * ? *)" ##### 毎月1日の深夜4時0分にアプリをローテーション（マスター完了後に実行される）
lambda_kms_key_arn = null

## S3
force_destroy       = true
log_expiration_days = 2

## ALB
### ALB関連
enable_deletion_protection       = false
desync_mitigation_mode           = "defensive"
enable_access_logs               = true
enable_connection_logs           = true
### ターゲットグループ関連
deregistration_delay             = 30
load_balancing_algorithm_type    = "round_robin"
health_check_interval            = 30
health_check_path                = "/health"
health_check_port                = "traffic-port"
health_check_protocol            = "HTTP"
health_check_timeout             = 5
health_check_healthy_threshold   = 5
health_check_unhealthy_threshold = 2
health_check_matcher             = "200"
### リスナー関連
routing_http_response_server_enabled = true

## WAF
scope = "REGIONAL"
enable_logging                      = true ##### WAFのログを保存するか否か
redacted_headers                    = ["authorization", "cookie", "x-forwarded-for"]
waf_managed_rules = {
  "CommonRuleSet" = {
    enabled         = true
    name            = "AWSManagedRulesCommonRuleSet"
    priority        = 1
    override_action = "count" ##### 初期段階では監視モード
    excluded_rules  = [] ##### 必要に応じて特定ルールを除外
    metric_name     = "AWSManagedRulesCommonRuleSetMetric"
  }
  "AdminProtection" = {
    enabled         = true
    name            = "AWSManagedRulesAdminProtectionRuleSet"
    priority        = 2
    override_action = "count"
    excluded_rules  = []
    metric_name     = "AWSManagedRulesAdminProtectionMetric"
  }
  "KnownBadInputs" = {
    enabled         = true
    name            = "AWSManagedRulesKnownBadInputsRuleSet"
    priority        = 3
    override_action = "count"
    excluded_rules  = []
    metric_name     = "AWSManagedRulesKnownBadInputsRuleSetMetric"
  }
  "SQLiRuleSet" = {
    enabled         = true
    name            = "AWSManagedRulesSQLiRuleSet"
    priority        = 4
    override_action = "count"
    excluded_rules  = []
    metric_name     = "AWSManagedRulesSQLiRuleSetMetric"
  }
  "IpReputationList" = {
    enabled         = true
    name            = "AWSManagedRulesAmazonIpReputationList"
    priority        = 5
    override_action = "count"
    excluded_rules  = []
    metric_name     = "AWSManagedRulesAmazonIpReputationListMetric"
  }
  "AnonymousIpList" = {
    enabled         = true
    name            = "AWSManagedRulesAnonymousIpList"
    priority        = 6
    override_action = "count"
    excluded_rules  = []
    metric_name     = "AWSManagedRulesAnonymousIpListMetric"
  }
}
waf_rate_limit_rules = {
  "IPRateLimit" = {
    enabled            = true
    name               = "IPRateLimitRule"
    priority           = 100
    limit              = 1000
    aggregate_key_type = "IP"
    action             = "count" 
    excluded_rules  = []
    metric_name     = "IPRateLimitMetric"
  }
}

## CloudTrail
enable_management_logging = true   # 管理イベントは常に有効（セキュリティ上重要）
cloudtrail_kms_key_id = null
include_global_service_events = true
is_multi_region_trail = true
enable_log_file_validation = true
event_selector_include_management_events = true
event_selector_read_write_type = "All" ##### 読み書きのイベントを記録
exclude_management_event_sources = []
enable_data_logging = false # データイベントは大量ログのため無効
enable_insight_logging = false     # インサイトイベントは追加コストのため無効

## VPC Flow Logs
enable_vpc_flow_logs = true
traffic_type = "ALL"                  # 全トラフィックを記録
max_aggregation_interval = 600        # 10分間隔（コスト効率重視）
log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${region} $${az-id}" ##### Athenaのフィールドとして使用
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
api_desired_count                   = 1
front_desired_count                 = 1
force_new_deployment                = true
platform_version                    = "LATEST"
enable_execute_command              = true
deployment_circuit_breaker_enable   = true
deployment_circuit_breaker_rollback = true
deployment_controller_type          = "ECS"
