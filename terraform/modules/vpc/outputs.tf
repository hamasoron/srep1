# アウトプットの定義
## VPC
output "vpc_create_protected_ngw_associations" {
  description = "Whether to create protected subnet and NAT gateway association (used in ECS module.)"
  value       = var.create_protected_ngw_associations
}

output "vpc_nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = [for ngw in aws_nat_gateway.terra_nat_gateway : ngw.id]
}

output "vpc_id" {
  description = "ID of the VPC (used in SG, ALB module, etc.)"
  value       = aws_vpc.terra_vpc.id
}

output "vpc_public_subnet_ids" {
  description = "ID of the public subnet (always get the ID of the public subnet that changes dynamically according to the AZ and NAT configuration. Used in ALB module, etc.)"
  value       = { for k, v in aws_subnet.terra_subnet : substr(k, 7, 2) => v.id if substr(k, 0, 6) == "public" }
}

output "vpc_private_subnet_ids" {
  description = "ID of the private subnet (always get the ID of the private subnet that changes dynamically according to the AZ and NAT configuration. Used in ECS module, etc.)"
  value       = { for k, v in aws_subnet.terra_subnet : substr(k, 8, 2) => v.id if substr(k, 0, 7) == "private" }
}

output "vpc_protected_subnet_ids" {
  description = "ID of the protected subnet (always get the ID of the protected subnet that changes dynamically according to the AZ and NAT configuration. Used in ECS module, etc.)"
  value       = { for k, v in aws_subnet.terra_subnet : substr(k, 10, 2) => v.id if substr(k, 0, 9) == "protected" }
}

output "vpc_route_table_ids" {
  description = "ID of the route table"
  value = concat(
    [for rt in aws_route_table.terra_route_table_public : rt.id],
    local.has_protected_subnets ? [for rt in aws_route_table.terra_route_table_protected : rt.id] : [],
    [for rt in aws_route_table.terra_route_table_private : rt.id]
  )
}

output "vpc_available_azs_names" {
  description = "List of actual AZ names used in VPC subnet configuration (used in RDS module for dynamic AZ mapping)"
  value       = distinct([for subnet in var.subnet_list : 
    lookup({
      "1a" = "ap-northeast-1a",
      "1c" = "ap-northeast-1c", 
      "1d" = "ap-northeast-1d"
    }, substr(subnet.name, -2, 2), "ap-northeast-1a")
  ])
}