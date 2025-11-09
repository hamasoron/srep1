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

## ECR
variable "image_tag_mutability" {
  description = "ECR image tag mutability"
  type        = string
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)  ##### mutable: 可変, immutable: 不変
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "ecr_force_delete" {
  description = "Whether to force delete ECR repository"
  type        = bool
}

variable "encryption_type" {
  description = "ECR image encryption type"
  type        = string
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be AES256 or KMS."
  }
}

variable "ecr_kms_key" {
  description = "KMS key for ECR image encryption"
  type        = string
  validation {
    condition     = var.ecr_kms_key == null || can(length(var.ecr_kms_key) > 0)
    error_message = "ecr_kms_key must be null or a non-empty string."
  }
}

variable "ecr_repositories" {
  description = "ECR repository settings"
  type = list(object({
    name             = string
    description      = string
    enable_lifecycle = optional(bool)
    lifecycle_count  = optional(number)
    scan_on_push     = optional(bool)
  }))
}
