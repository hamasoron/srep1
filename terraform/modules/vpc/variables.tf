# 変数の定義
## 全般
variable "system_name" {
  description = "The system name"
  type = string
  validation {
    condition     = length(var.system_name) > 0
    error_message = "system_name must not be empty."
  }
}

variable "environment_name" {
  description = "The environment name"
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
  description = "NAT Gateway Setting List (explicitly specify enabled/disabled for each AZ)"
  type = list(object({
    az      = string
    enabled = bool
    # 将来の拡張用（optional）
    instance_type = optional(string, "default")
    bandwidth     = optional(string, "default")
  }))
  default = [
    { az = "1a", enabled = false },
    { az = "1c", enabled = false },
    { az = "1d", enabled = false },
  ]
  validation {
    condition = alltrue([
      for ngw in var.nat_gateway_list : contains(["1a", "1c", "1d"], ngw.az)
    ])
    error_message = "az must be one of 1a, 1c, 1d."
  }
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create (0, 1, 2, 3) - for backward compatibility" ##### backward compatibility: 後方互換性
  type        = number
  default     = null
  validation {
    condition     = var.nat_gateway_count == null ? true : (var.nat_gateway_count >= 0 && var.nat_gateway_count <= 3)
    error_message = "nat_gateway_count must be between 0 and 3."
  }
}

variable "enable_auto_nat_calculation" {
  description = "Whether to automatically calculate the number of NAT Gateways based on the environment and AZ number - for backward compatibility"
  type        = bool
  default     = true
}

variable "use_all_azs_for_nat" {
  description = "Whether to configure NAT Gateways in all AZs in stg/prod environments with 3 AZs - for backward compatibility"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type = string
}

variable "map_public_ip_on_launch" {
  description = "Whether to automatically attach an Internet Gateway when launching a public subnet"
  type = bool
}

variable "subnet_list" {
  description = "The list of subnets"
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
}

variable "route_table_list" {
  description = "The list of route table"
  type = list(object({
    name         = string
    subnet       = string
    gateway_type = string
  }))
  validation {
    condition = alltrue([
      for route_table in var.route_table_list : contains(["public", "protected", "private"], route_table.name)
    ])
    error_message = "name must be one of public, protected, private."
  }
  validation {
    condition = alltrue([
      for route_table in var.route_table_list : contains(["1a", "1c", "1d"], route_table.subnet)
    ])
    error_message = "subnet must be one of 1a, 1c, 1d."
  }
  validation {
    condition = alltrue([
      for route_table in var.route_table_list : contains(["internet_gateway", "nat_gateway", "none"], route_table.gateway_type)
    ])
    error_message = "gateway_type must be one of internet_gateway, nat_gateway, none."
  }
}