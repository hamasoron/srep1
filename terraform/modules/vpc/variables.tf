# 変数の定義
## システム名の定義
variable "system_name" {
  type = string
}

## 環境名の定義
variable "environment_name" {
  type = string
}

## 保護された及びNATゲートウェイ関連の作成有無
variable "create_protected_ngw_associations" {
  type = bool
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
