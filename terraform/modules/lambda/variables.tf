# 変数の定義
## 全般
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
    condition     = contains(["dev", "stg", "prd"], var.environment_name)
    error_message = "environment_name must be one of dev, stg, prd."
  }
}

## VPC
variable "lambda_protected_or_public_subnet_ids" {
  description = "List of protected or public subnet IDs (used as a placeholder for the vpc module's outputs.tf)"
  type        = list(string)
}

## SG
variable "lambda_security_group_id" {
  description = "ID of the security group for Lambda functions (used as a placeholder for the sg module's outputs.tf)"
  type        = string
}

## IAM Role
variable "lambda_master_role_arn" {
  description = "ARN of the IAM role for the master user Lambda function (used as a placeholder for the iam_role module's outputs.tf)"
  type        = string
}

variable "lambda_app_role_arn" {
  description = "ARN of the IAM role for the app user Lambda function (used as a placeholder for the iam_role module's outputs.tf)"
  type        = string
}

## RDS
variable "db_rotation_writer_host" {
  description = "Writer endpoint of the Aurora cluster (used as a placeholder for the rds module's outputs.tf)"
  type        = string
}

variable "db_rotation_port" {
  description = "Port number of the Aurora cluster (used as a placeholder for the rds module's outputs.tf)"
  type        = number
}

variable "db_cluster_identifier" {
  description = "Identifier of the Aurora cluster (used for master user rotation)"
  type        = string
}

## Secrets Manager
variable "master_secret_arn" {
  description = "ARN of the secret for the master user (used as a placeholder for the secretsmanager module's outputs.tf)"
  type        = string
}

variable "app_secret_arn" {
  description = "ARN of the secret for the app user (used as a placeholder for the secretsmanager module's outputs.tf)"
  type        = string
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