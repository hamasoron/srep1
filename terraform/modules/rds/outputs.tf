# アウトプットの定義
## RDS
output "rds_cluster_id" {
  description = "ID of the Aurora cluster"
  value       = aws_rds_cluster.terra_rds_cluster.id
}

output "rds_cluster_writer_endpoint" {
  description = "Writer endpoint of the Aurora cluster (used in Lambda module, ECS module.)"
  value       = aws_rds_cluster.terra_rds_cluster.endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster (used in ECS module.)"
  value       = aws_rds_cluster.terra_rds_cluster.reader_endpoint
}

output "rds_cluster_port" {
  description = "Port number of the Aurora cluster (used in Lambda module, ECS module.)"
  value       = aws_rds_cluster.terra_rds_cluster.port
}

output "rds_cluster_database_name" {
  description = "Default database name of the Aurora cluster (used in ECS module.)"
  value       = aws_rds_cluster.terra_rds_cluster.database_name
}

output "rds_cluster_instance_details" {
  description = "Detailed information of the Aurora instances (ID, AZ, role)"
  value = [
    for i, instance in aws_rds_cluster_instance.terra_rds_cluster_instance : {
      id   = instance.id
      az   = instance.availability_zone
      role = i == 0 ? "writer" : "reader"
      promotion_tier = instance.promotion_tier
    }
  ]
}

output "rds_cluster_identifier" {
  description = "Identifier of the Aurora cluster (used in Lambda module for master user rotation only. Not used for app user rotation.)"
  value       = aws_rds_cluster.terra_rds_cluster.cluster_identifier
}
