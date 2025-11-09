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

## IAMロール
variable "cloudformation_stack_set_administration_role_arn" {
  description = "CloudFormation StackSet Administration Role ARN"
  type        = string
}

variable "cloudformation_stack_set_execution_role_name" {
  description = "CloudFormation StackSet Execution Role Name"
  type        = string
}

## GuardDuty CFn
variable "target_regions" {
  description = "Target regions"
  type        = list(string)
}

variable "finding_publishing_frequency" {
  description = "Finding publishing frequency"
  type        = string
  default     = "SIX_HOURS"
  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency)
    error_message = "Finding publishing frequency must be one of FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "ebs_malware_protection" {
  description = "EBS malware protection"
  type        = string
}

variable "eks_audit_logs" {
  description = "EKS audit logs"
  type        = string
}

variable "lambda_protection" {
  description = "Lambda protection"
  type        = string
}

variable "rds_protection" {
  description = "RDS protection"
  type        = string
}

variable "s3_protection" {
  description = "S3 protection"
  type        = string
}

variable "runtime_monitoring" {
  description = "Runtime monitoring"
  type        = string
}

variable "max_concurrent_count" {
  description = "Maximum concurrent count"
  type        = number
}

variable "failure_tolerance_count" {
  description = "Failure tolerance count"
  type        = number
}

variable "region_concurrency_type" {
  description = "Region concurrency type"
  type        = string
  validation {
    condition     = contains(["SEQUENTIAL", "PARALLEL"], var.region_concurrency_type)
    error_message = "Region concurrency type must be one of SEQUENTIAL or PARALLEL."
  }
} 

variable "retain_stack" {
  description = "Retain stack"
  type        = bool
}