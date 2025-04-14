# 変数の定義
variable "system_name" {
  description = "システム名"
  type        = string
}

variable "environment_name" {
  description = "環境名（prod, stg, dev）"
  type        = string
}

variable "region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "ecs_task_execution_role_arn" {
  description = "ECSタスク実行ロールのARN"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ECSタスクロールのARN"
  type        = string
}

variable "api_task_cpu" {
  description = "APIタスクのCPUユニット"
  type        = string
  default     = "256"  # 0.25 vCPU
}

variable "api_task_memory" {
  description = "APIタスクのメモリ（MB）"
  type        = string
  default     = "512"  # 0.5 GB
}

variable "front_task_cpu" {
  description = "フロントエンドタスクのCPUユニット"
  type        = string
  default     = "256"  # 0.25 vCPU
}

variable "front_task_memory" {
  description = "フロントエンドタスクのメモリ（MB）"
  type        = string
  default     = "512"  # 0.5 GB
}

variable "api_desired_count" {
  description = "APIサービスの希望するタスク数"
  type        = number
  default     = 1
}

variable "front_desired_count" {
  description = "フロントエンドサービスの希望するタスク数"
  type        = number
  default     = 1
}

variable "log_retention_days" {
  description = "CloudWatch Logsの保持期間（日数）"
  type        = number
  default     = 7
}

variable "protected_subnet_ids" {
  description = "ECSタスクを配置するプロテクテッドサブネットのID"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECSタスクに割り当てるセキュリティグループのID"
  type        = string
}

variable "api_target_group_arn" {
  description = "APIサービスのターゲットグループARN"
  type        = string
}

variable "front_target_group_arn" {
  description = "フロントエンドサービスのターゲットグループARN"
  type        = string
}

variable "api_ecr_repository_url" {
  description = "APIサービスのECRリポジトリURL"
  type        = string
}

variable "front_ecr_repository_url" {
  description = "フロントエンドサービスのECRリポジトリURL"
  type        = string
}

variable "vpc_id" {
  description = "プライベートDNSネームスペースを作成するVPCのID"
  type        = string
} 