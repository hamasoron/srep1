# 変数の定義
## 全般
variable "system_name" {
  description = "The system name"
  type = string
  validation {
    condition     = length(var.system_name) > 0
    error_message = "system_name must not be empty."
  }
}

variable "environment_name" {
  description = "The environment name"
  type = string
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment_name)
    error_message = "environment_name must be one of prod, stg, dev."
  }
}

## VPC
variable "vpc_id" {
  description = "VPC ID (used as a placeholder for the VPC module's outputs.tf)"
  type = string
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
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      description     = optional(string, null)
    }))
  }))
}