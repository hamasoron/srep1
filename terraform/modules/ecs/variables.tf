# 変数の定義
## 全般
variable "region_name" {
  description = "AWSリージョン"
  type        = string
}
variable "system_name" {
  description = "システム名"
  type        = string
}

variable "environment_name" {
  description = "環境名（prod, stg, dev）"
  type        = string
}

## VPC
variable "create_protected_ngw_associations" {
  description = "プロテクテッドサブネット及びNATゲートウェイ関連の作成有無（VPCモジュールのoutputs.tfの受け皿として定義）"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "プライベートDNSネームスペースを作成するVPCのID（VPCモジュールのoutputs.tfの受け皿として定義）"
  type        = string
} 

variable "protected_or_public_subnet_ids" {
  description = "ECSタスクを配置するサブネットのID（VPCモジュールのoutputs.tfの受け皿として定義）"
  type        = list(string)
}

variable "front_security_group_id" {
  description = "フロントエンドECSタスクに割り当てるセキュリティグループのID（SGモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "api_security_group_id" {
  description = "APIサービスECSタスクに割り当てるセキュリティグループのID（SGモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## IAM Role
variable "ecs_task_role_arn" {
  description = "ECSタスクロールのARN（IAMロールモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ECSタスク実行ロールのARN（IAMロールモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## SecretsManager
### シークレット関連
variable "db_master_secret_arn" {
  description = "RDSマスターユーザーのシークレットのARN（SecretsManagerモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## RDS
### 環境変数関連
variable "db_host" {
  description = "RDSのホスト名（RDSモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "db_port" {
  description = "RDSのポート番号（RDSモジュールのoutputs.tfの受け皿として定義）"
  type        = number
}

variable "db_name" {
  description = "RDSのデータベース名（RDSモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}


## ALB
variable "front_target_group_arn" {
  description = "フロントエンドサービスのターゲットグループARN（ALBモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## ECR
variable "api_ecr_repository_url" {
  description = "APIサービスのECRリポジトリURL（ECRモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "front_ecr_repository_url" {
  description = "フロントエンドサービスのECRリポジトリURL（ECRモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "db_initdata_ecr_repository_url" {
  description = "データ投入用のECRリポジトリURL（ECRモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "db_inituser_ecr_repository_url" {
  description = "DBユーザー作成用のECRリポジトリURL（ECRモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## CloudWatch Logs
variable "api_log_group_name" {
  description = "API用CloudWatch Logsグループの名前（CloudWatch Logsモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "front_log_group_name" {
  description = "フロントエンド用CloudWatch Logsグループの名前（CloudWatch Logsモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "db_initdata_log_group_name" {
  description = "DB初期データ用CloudWatch Logsグループの名前（CloudWatch Logsモジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

variable "db_inituser_log_group_name" {
  description = "DBユーザー作成用CloudWatch Logsグループの名前"
  type        = string
}

## ECS
### クラスター関連
variable "ecs_kms_key_id" {
  description = "KMSキーID（ECSタスク定義用）"
  type        = string
}

### タスク定義関連
variable "api_task_cpu" {
  description = "APIタスクのCPUユニット"
  type        = number
}

variable "api_task_memory" {
  description = "APIタスクのメモリ（MB）"
  type        = number
}

variable "front_task_cpu" {
  description = "フロントエンドタスクのCPUユニット"
  type        = number
}

variable "front_task_memory" {
  description = "フロントエンドタスクのメモリ（MB）"
  type        = number
}

variable "db_initdata_task_cpu" {
  description = "データ投入用タスクのCPUユニット"
  type        = number
}

variable "db_initdata_task_memory" {
  description = "データ投入用タスクのメモリ（MB）"
  type        = number
}

variable "db_inituser_task_cpu" {
  description = "ユーザー作成用タスクのCPUユニット"
  type        = number
}

variable "db_inituser_task_memory" {
  description = "ユーザー作成用タスクのメモリ（MB）"
  type        = number
}

### サービス関連
variable "api_desired_count" {
  description = "APIサービスの希望するタスク数"
  type        = number
}

variable "front_desired_count" {
  description = "フロントエンドサービスの希望するタスク数"
  type        = number
}

variable "force_new_deployment" {
  description = "ECSサービスの強制的なデプロイを有効にするかどうか"
  type        = bool
}

variable "platform_version" {
  description = "ECSのプラットフォームバージョン"
  type        = string
}

variable "enable_execute_command" {
  description = "ECSのコマンド実行を有効にするかどうか"
  type        = bool
}

variable "deployment_circuit_breaker_enable" {
  description = "デプロイの回路遮断器を有効にするかどうか"
  type        = bool
}

variable "deployment_circuit_breaker_rollback" {
  description = "デプロイの回路遮断器をロールバックするかどうか"
  type        = bool
}

variable "deployment_controller_type" {
  description = "デプロイ制御（ECS:ローリングデプロイ、CODE_DEPLOY:ブルー/グリーンデプロイか）"
  type        = string
}