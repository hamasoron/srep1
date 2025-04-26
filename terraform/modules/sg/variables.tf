# 変数の定義
## 全般
variable "system_name" {
  description = "システム名"
  type = string
}

variable "environment_name" {
  description = "環境名"
  type = string
}

## VPC
variable "vpc_id" {
  description = "VPCのID"
  type = string
}

## セキュリティグループ
variable "sg_definitions" {
  description = "セキュリティグループのリスト"
  type = map(object({
    description = string
    ingress = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
}