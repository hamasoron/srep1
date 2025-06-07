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

## IAM Role
variable "github_repo" {
  description = "GitHub repository name (owner/repository format, e.g. your-account-or-org/your-repo)"
  type        = string
  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repo)) ##### 正規表現。先頭から末尾まで「スラッシュを含まない1文字以上の文字列」/「スラッシュを含まない1文字以上の文字列。
    error_message = "github_repo must be in 'owner/repository' format (your-account-or-organization/your-repo)."
  }
}
