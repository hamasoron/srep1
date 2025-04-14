# 変数の定義
## SGの定義
variable "sg_definitions" {
  description = "List of security groups with rules"
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

## VPCのIDを定義
variable "vpc_id" {
  type = string
}

## システム名の定義
variable "system_name" {
  type = string
}

## 環境名の定義
variable "environment_name" {
  type = string
}