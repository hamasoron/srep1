variable "system_name" {
  description = "システム名"
  type        = string
}

variable "environment_name" {
  description = "環境名"
  type        = string
}

variable "vpc_id" {
  description = "VPCのID"
  type        = string
}

variable "security_group_id" {
  description = "ALB用のセキュリティグループID"
  type        = string
}

variable "public_subnet_ids" {
  description = "パブリックサブネットのIDリスト"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "ALBの削除保護を有効にするかどうか"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "HTTPSリスナーを有効にするかどうか"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "SSL証明書のARN"
  type        = string
  default     = ""
} 