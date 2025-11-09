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

## CloudMap
variable "cloudmap_service_arn" {
  description = "ARN of the CloudMap service (used as a placeholder for the CloudMap module's outputs.tf)"
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
    condition     = var.api_task_cpu >= 256 && var.api_task_cpu <= 16384
    error_message = "api_task_cpu must be between 256 and 16384 (minimum 0.25vCPU, maximum 16vCPU)."
  }
}

variable "api_task_memory" {
  description = "Memory for the API task (MB)"
  type        = number
  validation {
    condition     = var.api_task_memory >= 512 && var.api_task_memory <= 122880 ##### CPUとの関係性により、122880MB（120GB）が最大値（例: 0.25vCPUの場合、512MB, 1GB, 2GBのみ設定可能）
    error_message = "api_task_memory must be between 512MB and 122880MB (minimum 0.5GB, maximum 120GB)."
  }
}

variable "front_task_cpu" {
  description = "CPU units for the front-end task (vCPU)"
  type        = number
  validation {
    condition     = var.front_task_cpu >= 256 && var.front_task_cpu <= 16384
    error_message = "front_task_cpu must be between 256 and 16384 (minimum 0.25vCPU, maximum 16vCPU)."
  }
}

variable "front_task_memory" {
  description = "Memory for the front-end task (MB)"
  type        = number
  validation {
    condition     = var.front_task_memory >= 512 && var.front_task_memory <= 122880 ##### CPUとの関係性により、122880MB（120GB）が最大値（例: 0.25vCPUの場合、512MB, 1GB, 2GBのみ設定可能）
    error_message = "front_task_memory must be between 512MB and 122880MB (minimum 0.5GB, maximum 120GB)."
  }
}

variable "db_initdata_task_cpu" {
  description = "CPU units for the DB initialization task (vCPU)"
  type        = number
  validation {
    condition     = var.db_initdata_task_cpu >= 256 && var.db_initdata_task_cpu <= 16384
    error_message = "db_initdata_task_cpu must be between 256 and 16384 (minimum 0.25vCPU, maximum 16vCPU)."
  }
}

variable "db_initdata_task_memory" {
  description = "Memory for the DB initialization task (MB)"
  type        = number
  validation {
    condition     = var.db_initdata_task_memory >= 512 && var.db_initdata_task_memory <= 122880 ##### CPUとの関係性により、122880MB（120GB）が最大値（例: 0.25vCPUの場合、512MB, 1GB, 2GBのみ設定可能）
    error_message = "db_initdata_task_memory must be between 512MB and 122880MB (minimum 0.5GB, maximum 120GB)."
  }
}

variable "db_inituser_task_cpu" {
  description = "CPU units for the DB user creation task (vCPU)"
  type        = number
  validation {
    condition     = var.db_inituser_task_cpu >= 256 && var.db_inituser_task_cpu <= 16384
    error_message = "db_inituser_task_cpu must be between 256 and 16384 (minimum 0.25vCPU, maximum 16vCPU)."
  }
}

variable "db_inituser_task_memory" {
  description = "Memory for the DB user creation task (MB)"
  type        = number
  validation {
    condition     = var.db_inituser_task_memory >= 512 && var.db_inituser_task_memory <= 122880 ##### CPUとの関係性により、122880MB（120GB）が最大値（例: 0.25vCPUの場合、512MB, 1GB, 2GBのみ設定可能）
    error_message = "db_inituser_task_memory must be between 512MB and 122880MB (minimum 0.5GB, maximum 120GB)."
  }
}

### サービス関連
variable "api_desired_count" {
  description = "Desired number of tasks for the API service"
  type        = number
}

variable "front_desired_count" {
  description = "Desired number of tasks for the front-end service"
  type        = number
}

variable "force_new_deployment" {
  description = "Whether to enable force deployment for the ECS service"
  type        = bool
}

variable "platform_version" {
  description = "Platform version for ECS"
  type        = string
}

variable "enable_execute_command" {
  description = "Whether to enable ECS Exec for the ECS service"
  type        = bool
}

variable "deployment_circuit_breaker_enable" {
  description = "Whether to enable deployment circuit breaker for the ECS service"
  type        = bool
}

variable "deployment_circuit_breaker_rollback" {
  description = "Whether to rollback the deployment circuit breaker"
  type        = bool
}

variable "deployment_controller_type" {
  description = "deployment controller type (ECS: rolling deployment, CODE_DEPLOY: blue/green deployment)"
  type        = string
  validation {
    condition     = contains(["ECS", "CODE_DEPLOY"], var.deployment_controller_type)
    error_message = "deployment_controller_type must be one of ECS（rolling deployment）, CODE_DEPLOY（blue/green deployment）."
  }
}