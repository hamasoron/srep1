# IAMモジュール用変数の定義

## システム名
variable "system_name" {
  type = string
}

## 環境名
variable "environment_name" {
  type = string
}

variable "github_repo" {
  description = "GitHub リポジトリ名（組織名/リポジトリ名形式）"
  type        = string
  default     = "hamasoron/srep1"
}
