# 変数の値を定義
## 全般
region_name      = "ap-northeast-1"
system_name      = "srep1"
environment_name = "dev"

## VPC
create_protected_ngw_associations = true
vpc_cidr                          = "10.0.64.0/19"
subnet_list = [
  { name = "1a", cidr_block = "10.0.64.0/24", type = "public" },
  { name = "1c", cidr_block = "10.0.65.0/24", type = "public" },
  { name = "1a", cidr_block = "10.0.66.0/24", type = "protected" },
  { name = "1c", cidr_block = "10.0.67.0/24", type = "protected" },
  { name = "1a", cidr_block = "10.0.68.0/24", type = "private" },
  { name = "1c", cidr_block = "10.0.69.0/24", type = "private" },
]
route_table_list = [
  { name = "public", subnet = "1a", gateway_type = "internet_gateway" },
  { name = "public", subnet = "1c", gateway_type = "internet_gateway" },
  { name = "protected", subnet = "1a", gateway_type = "nat_gateway" },
  { name = "protected", subnet = "1c", gateway_type = "nat_gateway" },
  { name = "private", subnet = "1a", gateway_type = "none" },
  { name = "private", subnet = "1c", gateway_type = "none" },
]

## セキュリティグループ
sg_definitions = {
  "alb" = {
    description = "ALB Security Group"
    ingress = [{ from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }]
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
  "ecs-db-init" = {
    description = "ECS DB Init Security Group"
    ingress = []
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  }
  "rds" = {
    description = "RDS Security Group"
    ingress = [{ from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = [] }]
    egress = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  }
}

## IAMロール
github_repo = "hamasoron/srep1"

## RDS
### クラスター関連
db_engine = "aurora-mysql"
engine_version = "8.0.mysql_aurora.3.05.2"
database_name = "hamasorondb"
master_username = "hamasoron"
master_password = "i7V956YP"
backup_retention_period = 1
preferred_backup_window = "16:15-16:45"
skip_final_snapshot = true
deletion_protection = false
storage_encrypted = true
kms_key_id = null
apply_immediately = false
preferred_maintenance_window_cluster = "tue:16:45-tue:17:15"
enabled_cloudwatch_logs_exports = ["error", "slowquery"]
copy_tags_to_snapshot = true
### インスタンス関連
promotion_tier = 1
instance_class = "db.t4g.medium"
preferred_maintenance_window_instanceA = "tue:17:15-tue:17:45"
auto_minor_version_upgrade = true
enable_performance_insights = false
monitoring_interval = 0

## S3
force_destroy = true
log_expiration_days = 2

## ALB
enable_deletion_protection = false
deregistration_delay = 30
enable_access_logs = true
enable_connection_logs = true

## ECR
enable_ecr_lifecycle_policy = true
ecr_lifecycle_policy_count = 2

## ECS
api_desired_count = 1
front_desired_count = 1