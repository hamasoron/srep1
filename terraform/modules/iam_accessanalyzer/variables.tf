# 変数の定義
## 全般
variable "system_name" {
  description = "The system name"
  type        = string
  validation {
    condition     = length(var.system_name) > 0
    error_message = "system_name must not be empty."
  }
}

variable "environment_name" {
  description = "The environment name"
  type        = string
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment_name)
    error_message = "environment_name must be one of prod, stg, dev."
  }
}

## IAM AccessAnalyzer
variable "analyzer_type" {
  description = "Analyzer type (ACCOUNT or ORGANIZATION)"
  type        = string
  validation {
    condition     = contains(["ACCOUNT", "ORGANIZATION"], var.analyzer_type)
    error_message = "analyzer_type must be one of ACCOUNT, ORGANIZATION."
  }
}