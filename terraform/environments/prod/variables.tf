# 変数の定義
variable "region_name" {
  type = string
  description = "リージョン名"
}

variable "system_name" {
  type = string
  description = "システム名"
}

## 環境名の定義
variable "environment_name" {
  type = string
  description = "環境名"
}

## Route53設定
variable "route53_force_destroy" {
  description = "Route53ゾーンを削除する際にすべてのレコードを削除するかどうか"
  type        = bool
  default     = false
}

## ACM証明書設定
variable "certificate_subject_alternative_names" {
  description = "証明書のサブジェクト代替名（SAN）"
  type        = list(string)
  default     = []
}

## 保護された及びNATゲートウェイ関連の作成有無
variable "create_protected_ngw_associations" {
  type = bool
  description = "保護された及びNATゲートウェイ関連の作成有無"
}

## VPCのCIDRブロックを定義
variable "vpc_cidr" {
  type = string
}

## サブネットのリストを定義
variable "subnet_list" {
  type = list(object({
    name       = string
    cidr_block = string
    type       = string
  }))
}

## ルートテーブルのリストを定義
variable "route_table_list" {
  type = list(object({
    name         = string
    subnet       = string
    gateway_type = string
  }))
}

## セキュリティグループのリストを定義
variable "sg_definitions" {
  type = map(object({
    description = string
    ingress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
}

variable "db_password" {
  description = "RDSのマスターパスワード"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub リポジトリ名（組織名/リポジトリ名形式）"
  type        = string
  default     = "hamasoron/srep1"
}

variable "api_desired_count" {
  description = "APIサービスのタスク数"
  type        = number
  default     = 0
}

variable "front_desired_count" {
  description = "フロントエンドサービスのタスク数"
  type        = number
  default     = 0
}
