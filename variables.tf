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
variable "create_protected_ngw_associations" {
  description = "プロテクテッドサブネット及びNATゲートウェイ関連の作成有無"
  type = bool
}

variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type = string
}

variable "subnet_list" {
  description = "サブネットのリスト"
  type = list(object({
    name       = string
    cidr_block = string
    type       = string
  }))
}

variable "map_public_ip_on_launch" {
  description = "パブリックサブネットの場合、インターネットゲートウェイを起動時に自動的にアタッチするかどうか"
  type = bool
}

variable "route_table_list" {
  description = "ルートテーブルのリスト"
  type = list(object({
    name         = string
    subnet       = string
    gateway_type = string
  }))
}
