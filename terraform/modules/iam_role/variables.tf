# 変数の定義
## IAM Role
variable "github_repo" {
  description = "GitHub リポジトリ名（組織名/リポジトリ名形式）"
  type        = string
}

## Lambda関連の変数
variable "lambda_role_name" {
  description = "Lambda関数用のIAMロール名"
  type        = string
  default     = "LambdaRotationRole"
}

variable "secret_arns" {
  description = "Lambda関数がアクセスできるシークレットのARNリスト"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "リソースに適用するタグ"
  type        = map(string)
  default     = {}
}
