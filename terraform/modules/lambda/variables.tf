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
variable "lambda_master_role_arn" {
  description = "マスターユーザー用Lambda関数のIAMロールのARN（iam_roleモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "lambda_app_role_arn" {
  description = "アプリユーザー用Lambda関数のIAMロールのARN（iam_roleモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## RDS
variable "db_rotation_writer_host" {
  description = "RDSクラスターのエンドポイント（RDSモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "db_rotation_port" {
  description = "RDSクラスターのポート番号（RDSモジュールのoutputs.tfの受け皿として定義）"
  type        = number
}

variable "db_cluster_identifier" {
  description = "RDSクラスター識別子（マスターユーザーローテーション用）"
  type        = string
}

## Secrets Manager
variable "master_secret_arn" {
  description = "マスターユーザーのシークレットのARN（SecretsManagerモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "app_secret_arn" {
  description = "アプリユーザーのシークレットのARN（SecretsManagerモジュールのoutputs.tfの受け皿として定義）"
  type        = string
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
  description = "Lambda関数の同時実行数（nullの場合は制限なし）"
  type        = number
}

variable "enable_rotation_on_apply" {
  description = "初回terraform apply時にローテーションを有効にするかどうか（false=手動でローテーション実行）"
  type        = bool
}

variable "rotation_secrets" {
  description = "ローテーション対象のシークレットの名前"
  type        = list(string)
}

variable "master_rotation_schedule_expression" {
  description = "マスターローテーションのスケジュール（cron式）"
  type        = string
}

variable "app_rotation_schedule_expression" {
  description = "アプリローテーションのスケジュール（cron式）"
  type        = string
}

variable "lambda_kms_key_arn" {
  description = "Lambda関数で使用するKMSキーのARN（nullの場合はデフォルト暗号化）"
  type        = string
}