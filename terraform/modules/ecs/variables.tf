# 変数の定義
## 全般
variable "region_name" {
  description = "Region name"
  type        = string
  validation {
    condition     = contains(["ap-northeast-1"], var.region_name)
    error_message = "region_name must be one of ap-northeast-1."
  }
}

variable "system_name" {
  description = "System name"
  type        = string
  validation {
    condition     = length(var.system_name) > 0
    error_message = "system_name must not be empty."
  }
}

variable "environment_name" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment_name)
    error_message = "environment_name must be one of prod, stg, dev."
  }
}

## VPC
variable "create_protected_ngw_associations" {
  description = "Whether to create protected subnets and NAT gateways (VPC module's outputs.tf)"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of the VPC to create a private DNS namespace (VPC module's outputs.tf)"
  type        = string
} 

variable "ecs_protected_or_public_subnet_ids" {
  description = "ID of the subnets to place ECS tasks (VPC module's outputs.tf)"
  type        = list(string)
}

variable "front_security_group_id" {
  description = "ID of the security group to assign to the front-end ECS task (SG module's outputs.tf)"
  type        = string
}

variable "api_security_group_id" {
  description = "ID of the security group to assign to the API service ECS task (SG module's outputs.tf)"
  type        = string
}

## IAM Role
variable "ecs_task_role_arn" {
  description = "ARN of the ECS task role (IAM role module's outputs.tf)"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role (IAM role module's outputs.tf)"
  type        = string
}

## SecretsManager
### シークレット関連
variable "db_master_secret_arn" {
  description = "ARN of the RDS master user secret (SecretsManager module's outputs.tf)"
  type        = string
}

variable "db_app_secret_arn" {
  description = "ARN of the RDS application user secret (SecretsManager module's outputs.tf)"
  type        = string
}

## RDS
### 環境変数関連
variable "db_writer_host" {
  description = "Host name for RDS writer (RDS module's outputs.tf)"
  type        = string
}

variable "db_reader_host" {
  description = "Host name for RDS reader (RDS module's outputs.tf)"
  type        = string
}

variable "db_port" {
  description = "Port number for RDS (RDS module's outputs.tf)"
  type        = number
}

variable "db_name" {
  description = "Database name for RDS (RDS module's outputs.tf)"
  type        = string
}


## ALB
variable "front_target_group_arn" {
  description = "ARN of the front-end service target group (ALB module's outputs.tf)"
  type        = string
}

## ECR
variable "api_ecr_repository_url" {
  description = "URL of the API service ECR repository (ECR module's outputs.tf)"
  type        = string
}

variable "front_ecr_repository_url" {
  description = "URL of the front-end service ECR repository (ECR module's outputs.tf)"
  type        = string
}

variable "db_initdata_ecr_repository_url" {
  description = "URL of the ECR repository for data initialization (ECR module's outputs.tf)"
  type        = string
}

variable "db_inituser_ecr_repository_url" {
  description = "URL of the ECR repository for DB user creation (ECR module's outputs.tf)"
  type        = string
}

## CloudWatch Logs
variable "api_log_group_name" {
  description = "Name of the CloudWatch Logs group for API (CloudWatch Logs module's outputs.tf)"
  type        = string
}

variable "front_log_group_name" {
  description = "Name of the CloudWatch Logs group for front-end (CloudWatch Logs module's outputs.tf)"
  type        = string
}

variable "db_initdata_log_group_name" {
  description = "Name of the CloudWatch Logs group for DB initialization (CloudWatch Logs module's outputs.tf)"
  type        = string
}

variable "db_inituser_log_group_name" {
  description = "Name of the CloudWatch Logs group for DB user creation (CloudWatch Logs module's outputs.tf)"
  type        = string
}

## ECS
### クラスター関連
variable "ecs_kms_key_id" {
  description = "ID of the KMS key for ECS task definition"
  type        = string
  validation {
    condition     = var.ecs_kms_key_id == null || can(length(var.ecs_kms_key_id) > 0)
    error_message = "ecs_kms_key_id must be null or a non-empty string."
  }
}

### タスク定義関連
variable "api_task_cpu" {
  description = "CPU units for the API task (vCPU)"
  type        = number
  validation {
    condition     = contains([256, 512, 1024, 2048, 4096, 8192], var.api_task_cpu)
    error_message = "api_task_cpu must be one of 256, 512, 1024, 2048, 4096, 8192, 16384 (0.25 vCPU, 0.5 vCPU, 1 vCPU, 2 vCPU, 4 vCPU, 8 vCPU, 16 vCPU)."
  }
}

variable "api_task_memory" {
  description = "Memory for the API task (MB)"
  type        = number
  validation {
    condition     = var.api_task_memory >= 512 && var.api_task_memory <= 16384
    error_message = "api_task_memory must be between 512 and 16384 (1024MB（1GB） increments)."
  }
}

variable "front_task_cpu" {
  description = "フロントエンドタスクのCPUユニット"
  type        = number
}

variable "front_task_memory" {
  description = "フロントエンドタスクのメモリ（MB）"
  type        = number
}

variable "db_initdata_task_cpu" {
  description = "データ投入用タスクのCPUユニット"
  type        = number
}

variable "db_initdata_task_memory" {
  description = "データ投入用タスクのメモリ（MB）"
  type        = number
}

variable "db_inituser_task_cpu" {
  description = "ユーザー作成用タスクのCPUユニット"
  type        = number
}

variable "db_inituser_task_memory" {
  description = "ユーザー作成用タスクのメモリ（MB）"
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