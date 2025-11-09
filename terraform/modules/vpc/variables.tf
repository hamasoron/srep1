# 変数の定義
## 全般
variable "system_name" {
  description = "System name"
  type = string
  validation {
    condition     = length(var.system_name) > 0
    error_message = "system_name must not be empty."
  }
}

variable "environment_name" {
  description = "Environment name"
  type = string
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment_name)
    error_message = "environment_name must be one of prod, stg, dev."
  }
}

## VPC
variable "create_protected_ngw_associations" {
  description = "Whether to create protected subnet and NAT gateway association"
  type = bool
}

variable "nat_gateway_list" {
  description = "NAT Gateway Setting List (explicitly specify enabled/disabled for each AZ)."
  type = list(object({
    az      = string
    enabled = bool
  }))
  validation {
    condition = alltrue([
      for ngw in var.nat_gateway_list : contains(["1a", "1c", "1d"], ngw.az)
    ])
    error_message = "az must be one of 1a, 1c, 1d."
  }
  # エラーハンドリング1: nat_gateway_listでenabledがtrueの場合、create_protected_ngw_associationsもtrueである必要がある
  validation {
    condition = length([for ngw in var.nat_gateway_list : ngw if ngw.enabled]) == 0 || var.create_protected_ngw_associations
    error_message = "When any NAT gateway is enabled, create_protected_ngw_associations must be true."
  }
  # エラーハンドリング2: 同じAZに複数のNATゲートウェイを設定することを防ぐ
  validation {
    condition = length(var.nat_gateway_list) == length(distinct([for ngw in var.nat_gateway_list : ngw.az]))
    error_message = "Each AZ can only appear once in nat_gateway_list. Duplicate AZs are not allowed."
  }

}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type = string
}

variable "map_public_ip_on_launch" {
  description = "Whether to automatically attach an Internet Gateway when launching a public subnet"
  type = bool
}

variable "subnet_list" {
  description = "List of subnets"
  type = list(object({
    name       = string
    cidr_block = string
    type       = string
  }))
  validation {
    condition = alltrue([
      for subnet in var.subnet_list : contains(["1a", "1c", "1d"], subnet.name)
    ])
    error_message = "name must be one of 1a, 1c, 1d."
  }
  validation {
    condition = alltrue([
      for subnet in var.subnet_list : contains(["public", "protected", "private"], subnet.type)
    ])
    error_message = "type must be one of public, protected, private."
  }
  # エラーハンドリング3: create_protected_ngw_associations = falseの場合、subnet_listのtypeにprotectedが存在してはいけない
  validation {
    condition = var.create_protected_ngw_associations || length([
      for subnet in var.subnet_list : subnet if subnet.type == "protected"
    ]) == 0
    error_message = "Protected subnets cannot exist when create_protected_ngw_associations is false."
  }
  # エラーハンドリング4: create_protected_ngw_associations = trueの場合、subnet_listにprotectedが存在する必要がある
  validation {
    condition = !var.create_protected_ngw_associations || length([
      for subnet in var.subnet_list : subnet if subnet.type == "protected"
    ]) > 0
    error_message = "When create_protected_ngw_associations is true, protected subnets must exist in subnet_list."
  }
  # エラーハンドリング5: subnet_listのtypeにprotectedが存在する場合、少なくとも1つ以上nat_gateway_listのenabledがtrueである必要がある
  validation {
    condition = length([for subnet in var.subnet_list : subnet if subnet.type == "protected"]) == 0 || length([for ngw in var.nat_gateway_list : ngw if ngw.enabled]) > 0
    error_message = "When protected subnets exist, at least one NAT gateway must be enabled in nat_gateway_list."
  }
}

variable "route_table_list" {
  description = "List of route table"
  type = list(object({
    name         = string
    subnet       = string
    gateway_type = string
  }))
  validation {
    condition = alltrue([
      for route_table in var.route_table_list : contains(["public", "protected", "private"], route_table.name)
    ])
    error_message = "Name must be one of public, protected, private."
  }
  validation {
    condition = alltrue([
      for route_table in var.route_table_list : contains(["1a", "1c", "1d"], route_table.subnet)
    ])
    error_message = "Subnet must be one of 1a, 1c, 1d."
  }
  validation {
    condition = alltrue([
      for route_table in var.route_table_list : contains(["internet_gateway", "nat_gateway", "none"], route_table.gateway_type)
    ])
    error_message = "Gateway_type must be one of internet_gateway, nat_gateway, none."
  }
  # エラーハンドリング6: route_table_listの数とsubnet_listの数が一致している必要がある
  validation {
    condition = length(var.route_table_list) == length(var.subnet_list)
    error_message = "The number of route_table_list must match the number of subnet_list."
  }
  # エラーハンドリング7: publicルートテーブルはinternet_gatewayを、privateルートテーブルはnoneを指定する必要がある
  validation {
    condition = alltrue([
      for rt in var.route_table_list : 
      (rt.name == "public" && rt.gateway_type == "internet_gateway") ||
      (rt.name == "private" && rt.gateway_type == "none") ||
      (rt.name == "protected" && contains(["nat_gateway", "none"], rt.gateway_type))
    ])
    error_message = "Route table gateway_type must match the subnet type: public->internet_gateway, private->none, protected->nat_gateway or none."
  }
  # エラーハンドリング8: create_protected_ngw_associations = falseの場合、route_table_listにprotectedが存在してはいけない
  validation {
    condition = var.create_protected_ngw_associations || length([
      for rt in var.route_table_list : rt if rt.name == "protected"
    ]) == 0
    error_message = "Protected route tables cannot exist when create_protected_ngw_associations is false."
  }
  # エラーハンドリング9: create_protected_ngw_associations = trueの場合、route_table_listにprotectedが存在する必要がある
  validation {
    condition = !var.create_protected_ngw_associations || length([
      for rt in var.route_table_list : rt if rt.name == "protected"
    ]) > 0
    error_message = "When create_protected_ngw_associations is true, protected route tables must exist in route_table_list."
  }

  # エラーハンドリング10: protectedルートテーブルでnat_gatewayを指定する場合、少なくとも1つのNATゲートウェイが有効である必要がある
  validation {
    condition = alltrue([
      for rt in var.route_table_list : 
      rt.name != "protected" || rt.gateway_type != "nat_gateway" || 
      length([for ngw in var.nat_gateway_list : ngw if ngw.enabled]) > 0
    ])
    error_message = "When a protected route table uses nat_gateway, at least one NAT gateway must be enabled in nat_gateway_list."
  }
  # エラーハンドリング11: サブネットとルートテーブルの対応関係（同じAZ・同じタイプ）の整合性チェック
  validation {
    condition = alltrue([
      for rt in var.route_table_list : 
      length([for subnet in var.subnet_list : subnet if subnet.name == rt.subnet && subnet.type == rt.name]) > 0
    ])
    error_message = "Each route table must have a corresponding subnet with the same AZ and type."
  }
}