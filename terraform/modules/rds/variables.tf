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
    condition     = contains(["prod", "stg", "dev"], var.environment_name)
    error_message = "environment_name must be one of prod, stg, dev."
  }
}

## VPC
variable "private_subnet_ids" {
  description = "List of private subnet IDs (VPC module's outputs.tf)"
  type        = list(string)
}

variable "available_azs_names" {
  description = "List of actual AZ names used in VPC subnet configuration (VPC module's outputs.tf)"
  type        = list(string)
}

## SG
variable "rds_security_group_id" {
  description = "ID of security group (SG module's outputs.tf)"
  type        = string
}

## Secrets Manager
variable "master_username" {
  description = "Master username (Secrets Manager module's outputs.tf)"
  type        = string
}

variable "master_password" {
  description = "Master password (Secrets Manager module's outputs.tf)"
  type        = string
  sensitive   = true
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
    error_message = "engine_version must not be empty."
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
  description = "Monitoring interval" ##### 拡張モニタリングの間隔（0は無効）
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
}

variable "auto_minor_version_upgrade" {
  description = "Auto minor version upgrade"
  type        = bool
}

variable "publicly_accessible" {
  description = "Publicly accessible"
  type        = bool
}

variable "deployment_mode" {
  description = "Deployment mode selection for Aurora cluster (note: writer_only is only valid for 1AZ)"
  type        = string
  default     = "writer_only"
  validation {
    condition = contains([
      "writer_only",           # Writer 1台のみ（全AZ対応）
      "writer_with_1_reader",  # Writer 1台 + Reader 1台（2AZ以上で有効）
      "writer_with_2_readers"  # Writer 1台 + Reader 2台（3AZで最適）
    ], var.deployment_mode)
    error_message = "deployment_mode must be one of: writer_only, writer_with_1_reader, writer_with_2_readers."
  }
}

variable "preferred_maintenance_window_base" {
  description = "Base maintenance window for the first instance (UTC)"
  type        = string
  validation {
    condition     = can(regex("^(sun|mon|tue|wed|thu|fri|sat):[0-9]{2}:[0-9]{2}-(sun|mon|tue|wed|thu|fri|sat):[0-9]{2}:[0-9]{2}$", var.preferred_maintenance_window_base))
    error_message = "Maintenance window must be in format 'ddd:hh:mm-ddd:hh:mm' (e.g., 'tue:17:15-tue:17:45')."
  }
}