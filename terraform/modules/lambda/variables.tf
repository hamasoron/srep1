# 変数の定義
## 全般
variable "system_name" {  
  description = "システム名"
  type        = string
}

variable "environment_name" {
  description = "環境名"
  type        = string
}

## VPC
variable "lambda_protected_or_public_subnet_ids" {
  description = "Lambda関数を配置するサブネットIDのリスト（vpcモジュールのoutputs.tfの受け皿として定義）"
  type        = list(string)
}

## SG
variable "lambda_security_group_id" {
  description = "Lambda関数用のセキュリティグループID（sgモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## IAM Role
variable "lambda_role_arn" {
  description = "Lambda関数用のIAMロールのARN（iam_roleモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## RDS
variable "db_lotation_writer_host" {
  description = "RDSクラスターのエンドポイント（RDSモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "db_lotation_port" {
  description = "RDSクラスターのポート番号（RDSモジュールのoutputs.tfの受け皿として定義）"
  type        = number
}

## Secrets Manager
variable "rotation_secret_arns" {
  description = "Lambda関数でローテーションするシークレットのマップ（SecretsManagerモジュールのoutputs.tfの受け皿として定義）"
  type        = map(string)
  default     = {}
}

## Lambda
variable "memory_size" {
  description = "Lambda関数のメモリサイズ（MB）"
  type        = number
}

variable "timeout" {
  description = "Lambda関数のタイムアウト秒数"
  type        = number
}

variable "reserved_concurrent_executions" {
  description = "Lambda関数の同時実行数"
  type        = number
}

variable "schedule_expression" {
  description = "シークレットを自動的にローテーションする日数"
  type        = string
}