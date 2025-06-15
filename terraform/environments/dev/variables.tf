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
  }))
  validation {
    condition = alltrue([
      for ngw in var.nat_gateway_list : contains(["1a", "1c", "1d"], ngw.az)
    ])
    error_message = "az must be one of 1a, 1c, 1d."
  }
  # エラーハンドリング1: nat_gateway_listでenabledがtrueの場合、create_protected_ngw_associationsもtrueである必要がある
  validation {
    condition = length([for ngw in var.nat_gateway_list : ngw if ngw.enabled]) == 0 || var.create_protected_ngw_associations
    error_message = "When any NAT gateway is enabled, create_protected_ngw_associations must be true."
  }
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
  # エラーハンドリング2: create_protected_ngw_associations = false の場合、protectedサブネットが存在してはいけない
  validation {
    condition = var.create_protected_ngw_associations || length([
      for subnet in var.subnet_list : subnet if subnet.type == "protected"
    ]) == 0
    error_message = "Protected subnets cannot exist when create_protected_ngw_associations is false."
  }
  # エラーハンドリング3: create_protected_ngw_associations = true の場合、protectedサブネットが存在する必要がある
  validation {
    condition = !var.create_protected_ngw_associations || length([
      for subnet in var.subnet_list : subnet if subnet.type == "protected"
    ]) > 0
    error_message = "When create_protected_ngw_associations is true, protected subnets must exist in subnet_list."
  }
  # エラーハンドリング4: subnet_listのtypeにprotectedが存在する場合、少なくとも1つ以上nat_gateway_listのenabledがtrueである必要がある
  validation {
    condition = length([for subnet in var.subnet_list : subnet if subnet.type == "protected"]) == 0 || length([for ngw in var.nat_gateway_list : ngw if ngw.enabled]) > 0
    error_message = "When protected subnets exist, at least one NAT gateway must be enabled in nat_gateway_list."
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
  # エラーハンドリング5: route_table_listの数とsubnet_listの数が一致している必要がある
  validation {
    condition = length(var.route_table_list) == length(var.subnet_list)
    error_message = "The number of route_table_list must match the number of subnet_list."
  }
  # エラーハンドリング6: publicルートテーブルはinternet_gatewayを、privateルートテーブルはnoneを指定する必要がある
  validation {
    condition = alltrue([
      for rt in var.route_table_list : 
      (rt.name == "public" && rt.gateway_type == "internet_gateway") ||
      (rt.name == "private" && rt.gateway_type == "none") ||
      (rt.name == "protected" && contains(["nat_gateway", "none"], rt.gateway_type))
    ])
    error_message = "public route table must specify internet_gateway, private route table must specify none, protected route table must specify nat_gateway or none."
  }
  # エラーハンドリング7: create_protected_ngw_associations = false の場合、protectedルートテーブルが存在してはいけない
  validation {
    condition = var.create_protected_ngw_associations || length([
      for rt in var.route_table_list : rt if rt.name == "protected"
    ]) == 0
    error_message = "Protected route tables cannot exist when create_protected_ngw_associations is false."
  }
  # エラーハンドリング8: create_protected_ngw_associations = true の場合、protectedルートテーブルが存在する必要がある
  validation {
    condition = !var.create_protected_ngw_associations || length([
      for rt in var.route_table_list : rt if rt.name == "protected"
    ]) > 0
    error_message = "When create_protected_ngw_associations is true, protected route tables must exist in route_table_list."
  }
  # エラーハンドリング9: protectedルートテーブルは少なくとも1つ以上nat_gateway_listのenabledがtrueである必要がある
  validation {
    condition = alltrue([
      for rt in var.route_table_list : 
      rt.name != "protected" || rt.gateway_type != "nat_gateway" || 
      length([for ngw in var.nat_gateway_list : ngw if ngw.enabled]) > 0
    ])
    error_message = "When a protected route table uses nat_gateway, at least one NAT gateway must be enabled in nat_gateway_list."
  }
  # エラーハンドリング10: サブネットとルートテーブルの対応関係（同じAZ・同じタイプ）の整合性チェック
  validation {
    condition = alltrue([
      for rt in var.route_table_list : 
      length([for subnet in var.subnet_list : subnet if subnet.name == rt.subnet && subnet.type == rt.name]) > 0
    ])
    error_message = "Each route table must have a corresponding subnet with the same AZ and type."
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
  description = "ID of KMS key for CloudWatch Logs"
  type        = string
  validation {
    condition     = var.cloudwatch_logs_kms_key_id == null || can(length(var.cloudwatch_logs_kms_key_id) > 0)
    error_message = "cloudwatch_logs_kms_key_id must be null or a non-empty string."
  }
}

## Secrets Manager
variable "secrets_list" {
  description = "List of secrets managed by SecretsManager"
  type = list(object({
    name     = string
    username = string
  }))
}

variable "recovery_window_in_days" {
  description = "Recovery window in days after deletion"
  type        = number
  validation {
    condition     = var.recovery_window_in_days == 0 || (var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30)
    error_message = "recovery_window_in_days must be 0 or an integer between 7 and 30."
  }
}

variable "secretsmanager_kms_key_id" {
  description = "ID of KMS key for SecretsManager"
  type        = string
  validation {
    condition     = var.secretsmanager_kms_key_id == null || can(length(var.secretsmanager_kms_key_id) > 0)
    error_message = "secretsmanager_kms_key_id must be null or a non-empty string."
  }
}

## RDS
### クラスター関連
variable "db_engine" {
  description = "Database engine"
  type        = string
  validation {
    condition     = contains(["aurora-mysql", "aurora-postgresql"], var.db_engine)
    error_message = "db_engine must be one of aurora-mysql, aurora-postgresql."
  }
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  validation {
    condition     = length(var.engine_version) > 0
    error_message = "engine_version must be a non-empty string."
  }
}

variable "database_name" {
  description = "Database name"
  type        = string
  validation {
    condition     = length(var.database_name) > 0
    error_message = "database_name must not be empty."
  }
}

variable "backup_retention_period" {
  description = "Backup retention period (days)"
  type        = number
  validation {
    condition     = var.backup_retention_period > 0
    error_message = "backup_retention_period must be greater than 0."
  }
}

variable "preferred_backup_window" {
  description = "Backup window (UTC)"
  type        = string
  validation {
    condition     = length(var.preferred_backup_window) > 0
    error_message = "preferred_backup_window must not be empty."
  }
}

variable "skip_final_snapshot" {
  description = "Create final snapshot on deletion"
  type        = bool
}

variable "deletion_protection" {
  description = "Deletion protection"
  type        = bool
}

variable "storage_encrypted" {
  description = "Storage encryption"
  type        = bool
}

variable "rds_kms_key_id" {
  description = "ID of KMS key for storage encryption"
  type        = string
  validation {
    condition     = var.rds_kms_key_id == null || can(length(var.rds_kms_key_id) > 0)
    error_message = "rds_kms_key_id must be null or a non-empty string."
  }
}

variable "apply_immediately" {
  description = "Apply immediately or during maintenance window (parameter update)"
  type        = bool
}

variable "preferred_maintenance_window_cluster" {
  description = "Maintenance window (UTC)"
  type        = string
  validation {
    condition     = length(var.preferred_maintenance_window_cluster) > 0
    error_message = "preferred_maintenance_window_cluster must not be empty."
  }
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Enabled CloudWatch Logs exports"
  type        = list(string)
}

variable "performance_insights_enabled" {
  description = "Performance Insights enabled"
  type        = bool
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period (days)"
  type        = number
  validation {
    condition     = var.performance_insights_retention_period > 0
    error_message = "performance_insights_retention_period must be greater than 0."
  }
}

variable "performance_insights_kms_key_id" {
  description = "Performance Insights KMS key ID"
  type        = string
  validation {
    condition     = var.performance_insights_kms_key_id == null || can(length(var.performance_insights_kms_key_id) > 0)
    error_message = "performance_insights_kms_key_id must be null or a non-empty string."
  }
}

variable "monitoring_interval" {
  description = "Monitoring interval"
  type        = number
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "monitoring_interval must be one of 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "monitoring_role_arn" {
  description = "ARN of monitoring role"
  type        = string
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to snapshot"
  type        = bool
}

### インスタンス関連
variable "instance_class" {
  description = "RDS instance class"
  type        = string
  validation {
    condition     = length(var.instance_class) > 0
    error_message = "instance_class must not be empty."
  }
}

variable "auto_minor_version_upgrade" {
  description = "Auto minor version upgrade"
  type        = bool
}

variable "preferred_maintenance_window_base" {
  description = "Base maintenance window for the first instance (UTC)"
  type        = string
  validation {
    condition     = can(regex("^(sun|mon|tue|wed|thu|fri|sat):[0-9]{2}:[0-9]{2}-(sun|mon|tue|wed|thu|fri|sat):[0-9]{2}:[0-9]{2}$", var.preferred_maintenance_window_base))
    error_message = "Maintenance window must be in format 'ddd:hh:mm-ddd:hh:mm' (e.g., 'tue:17:15-tue:17:45')."
  }
}

variable "publicly_accessible" {
  description = "Publicly accessible"
  type        = bool
}

variable "deployment_mode" {
  description = "Deployment mode selection for Aurora cluster (note: writer_only is only valid for 1AZ)"
  type        = string
  validation {
    condition = contains([
      "writer_only",           # Writer 1台のみ（全AZ対応） 
      "writer_with_1_reader",  # Writer 1台 + Reader 1台（2AZ以上で有効）
      "writer_with_2_readers"  # Writer 1台 + Reader 2台（3AZで最適）
    ], var.deployment_mode)
    error_message = "deployment_mode must be one of: writer_only, writer_with_1_reader, writer_with_2_readers."
  }
}

## Lambda
variable "memory_size" {
  description = "Memory size of the Lambda function (MB)"
  type        = number
  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "memory_size must be between 128MB and 10240MB (10GB)."
  }
}

variable "timeout" {
  description = "Timeout of the Lambda function (seconds)"
  type        = number
  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "timeout must be between 1 second and 900 seconds (15 minutes)."
  }
}

variable "reserved_concurrent_executions" {
  description = "Number of concurrent executions of the Lambda function (null means no limit)"
  type        = number
  validation {  
    condition     = var.reserved_concurrent_executions == null || try(var.reserved_concurrent_executions >= 0 && var.reserved_concurrent_executions <= 1000, false)
    error_message = "reserved_concurrent_executions must be null (no limit, up to account limit) or between 0 (throttling) and 1000."
  }
}

variable "enable_rotation_on_apply" {
  description = "Whether to enable rotation on the first terraform apply"
  type        = bool
}

variable "rotation_secrets" {
  description = "List of names of the secrets to be rotated"
  type        = list(string)
}

variable "master_rotation_schedule_expression" {
  description = "Schedule for the master rotation (cron expression)"
  type        = string
}

variable "app_rotation_schedule_expression" {
  description = "Schedule for the app rotation (cron expression)"
  type        = string
}

variable "lambda_kms_key_arn" {
  description = "ARN of the KMS key used by the Lambda function (null means default encryption)"
  type        = string
  validation {
    condition     = var.lambda_kms_key_arn == null || can(length(var.lambda_kms_key_arn) > 0)
    error_message = "lambda_kms_key_arn must be null or a non-empty string."
  }
}

## S3
variable "force_destroy" {
  description = "Force destroy S3 bucket"
  type        = bool
}

variable "log_expiration_days" {
  description = "Log expiration days"
  type        = number
}

## ALB
### ALB関連
variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for ALB"
  type        = bool
}

variable "desync_mitigation_mode" {
  description = "Mode of desync mitigation for ALB"
  type        = string
  validation {
    condition     = contains(["defensive", "strictest", "monitor"], var.desync_mitigation_mode)
    error_message = "desync_mitigation_mode must be one of defensive, strictest, monitor."
  }
}

variable "enable_access_logs" {
  description = "Whether to enable access logs for ALB"
  type        = bool
}

variable "enable_connection_logs" {
  description = "Whether to enable connection logs for ALB"
  type        = bool
}

### ターゲットグループ関連
variable "deregistration_delay" {
  description = "Deregistration delay time for target group"
  type        = number
  validation {
    condition     = var.deregistration_delay >= 0 && var.deregistration_delay <= 3600
    error_message = "deregistration_delay must be between 0 and 3600（default: 300）."
  }
}

variable "load_balancing_algorithm_type" {
  description = "Type of load balancing algorithm"
  type        = string
  validation {
    condition     = contains(["round_robin", "least_connections", "weighted_routing"], var.load_balancing_algorithm_type)
    error_message = "load_balancing_algorithm_type must be one of round_robin, least_connections, weighted_routing（default: round_robin）."
  }
}

variable "health_check_interval" {
  description = "Interval of health check"
  type        = number
  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "health_check_interval must be between 5 and 300（default: 30 seconds）."
  }
}

variable "health_check_path" {
  description = "Path of health check"
  type        = string
}

variable "health_check_port" {
  description = "Port of health check"
  type        = string
}

variable "health_check_protocol" {
  description = "Protocol of health check"
  type        = string
}

variable "health_check_timeout" {
  description = "Timeout of health check"
  type        = number
  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 120 
    error_message = "health_check_timeout must be between 2 and 120."
  }
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold of health check"
  type        = number
  validation {
    condition     = var.health_check_healthy_threshold >= 2 && var.health_check_healthy_threshold <= 10
    error_message = "health_check_healthy_threshold must be between 2 and 10（default: 3）."
  }
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold of health check"
  type        = number
  validation {
    condition     = var.health_check_unhealthy_threshold >= 2 && var.health_check_unhealthy_threshold <= 10
    error_message = "health_check_unhealthy_threshold must be between 2 and 10（default: 3）."
  }
}

variable "health_check_matcher" {
  description = "Matcher of health check"
  type        = string
}

### リスナー関連
variable "routing_http_response_server_enabled" {
  description = "Whether to enable server header for HTTP response"
  type        = bool
}

## CloudTrail
variable "enable_management_logging" {
  description = "Whether to enable management event logging"
  type        = bool
}

variable "cloudtrail_kms_key_id" {
  description = "ID of the KMS key for CloudTrail logs"
  type        = string
}

variable "include_global_service_events" {
  description = "Whether to include global service events"
  type        = bool
}

variable "is_multi_region_trail" {
  description = "Whether to enable multi-region trail"
  type        = bool
}

variable "enable_log_file_validation" {
  description = "Whether to enable log file validation"
  type        = bool
}

variable "event_selector_include_management_events" {
  description = "Whether to include management events"
  type        = bool
}

variable "event_selector_read_write_type" {
  description = "Whether to record read/write events"
  type        = string
}

variable "exclude_management_event_sources" {
  description = "Event sources to exclude from management events"
  type        = list(string)
}

variable "enable_data_logging" {
  description = "Whether to enable data event logging"
  type        = bool
}

variable "enable_insight_logging" {
  description = "Whether to enable insight event logging"
  type        = bool
}

## VPC Flow Logs
variable "enable_vpc_flow_logs" {
  description = "Whether to enable VPC Flow Logs"
  type        = bool
}

variable "traffic_type" {
  description = "Traffic type to record (ALL, ACCEPT, REJECT)"
  type        = string
  validation {
    condition = contains(["ALL", "ACCEPT", "REJECT"], var.traffic_type)
    error_message = "traffic_type must be ALL, ACCEPT, or REJECT."
  }
}

variable "max_aggregation_interval" {
  description = "Maximum aggregation interval for flow logs (60 seconds or 600 seconds)"
  type        = number
  validation {
    condition = contains([60, 600], var.max_aggregation_interval)
    error_message = "max_aggregation_interval must be 60 or 600."
  }
}

variable "log_format" {
  description = "Log format for VPC Flow Logs"
  type        = string
}

variable "destination_options" {
  description = "Destination options for VPC Flow Logs"
  type = object({
    file_format                = string
    hive_compatible_partitions = bool
    per_hour_partition         = bool
  })
  validation {
    condition = contains(["plain-text", "parquet"], var.destination_options.file_format)
    error_message = "destination_options.file_format must be 'plain-text' or 'parquet'."
  }
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
