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

## VPC
variable "vpc_id" {
  description = "ID of the VPC (used as a placeholder for the VPC module's outputs.tf)"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs (used as a placeholder for the VPC module's outputs.tf)"
  type        = list(string)
}

## SG
variable "security_group_id" {
  description = "ID of the security group for ALB (used as a placeholder for the SG module's outputs.tf)"
  type        = string
}

## ACM
variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS listener (used as a placeholder for the ACM module's outputs.tf)"
  type        = string
}

## S3
variable "s3_alb_logs_bucket_name" {
  description = "Name of the ALB log bucket (used as a placeholder for the S3 module's outputs.tf)"
  type        = string
}

## ALB
### ALB関連
variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for ALB"
  type        = bool
}

variable "desync_mitigation_mode" {
  description = "Mode of desync mitigation for ALB" ##### desync_mitigation（デシンク・ミティゲーション）: 非同期緩和
  type        = string
  validation {
    condition     = contains(["defensive", "strictest", "monitor"], var.desync_mitigation_mode)
    error_message = "desync_mitigation_mode must be one of monitor, defensive, strictest." #####  monitor: 監視、defensive: 防御的、strictest: 厳しい
  }
}

variable "enable_access_logs" {
  description = "Whether to enable access logs for ALB"
  type        = bool
}

variable "enable_connection_logs" {
  description = "Whether to enable connection logs for ALB"
  type        = bool
}

### ターゲットグループ関連
variable "deregistration_delay" {
  description = "Deregistration delay time for target group" ##### deregistration delay（登録解除遅延）:コネクション・ドレーニング
  type        = number
  validation {
    condition     = var.deregistration_delay >= 0 && var.deregistration_delay <= 3600
    error_message = "deregistration_delay must be between 0 and 3600（default: 300）."
  }
}

variable "load_balancing_algorithm_type" {
  description = "Type of load balancing algorithm"
  type        = string
  validation {
    condition     = contains(["round_robin", "least_connections", "weighted_routing"], var.load_balancing_algorithm_type)
    error_message = "load_balancing_algorithm_type must be one of round_robin, least_connections, weighted_routing（default: round_robin）."
  }
}

variable "health_check_interval" {
  description = "Interval of health check"
  type        = number
  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "health_check_interval must be between 5 and 300（default: 30 seconds）."
  }
}

variable "health_check_path" {
  description = "Path of health check"
  type        = string
}

variable "health_check_port" {
  description = "Port of health check"
  type        = string
}

variable "health_check_protocol" {
  description = "Protocol of health check"
  type        = string
}

variable "health_check_timeout" {
  description = "Timeout of health check"
  type        = number
  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 120
    error_message = "health_check_timeout must be between 2 and 120."
  }
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold of health check"
  type        = number
  validation {
    condition     = var.health_check_healthy_threshold >= 2 && var.health_check_healthy_threshold <= 10
    error_message = "health_check_healthy_threshold must be between 2 and 10（default: 3）."
  }
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold of health check"
  type        = number
  validation {
    condition     = var.health_check_unhealthy_threshold >= 2 && var.health_check_unhealthy_threshold <= 10
    error_message = "health_check_unhealthy_threshold must be between 2 and 10（default: 3）."
  }
}

variable "health_check_matcher" {
  description = "Matcher of health check" ##### matcher: マッチャー（成功か失敗かを判断するための条件）
  type        = string
}

### リスナー関連
variable "routing_http_response_server_enabled" {
  description = "Whether to enable server header for HTTP response"
  type        = bool
}