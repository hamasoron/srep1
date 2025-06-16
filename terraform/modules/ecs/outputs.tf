# アウトプットの定義
## ECS
output "ecs_cluster_id" {
  description = "ID of the ECS cluster (Used for GitHub Actions)"
  value       = aws_ecs_cluster.terra_ecs_cluster.id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster (Used for ECS Exec)"
  value       = aws_ecs_cluster.terra_ecs_cluster.name
}

output "ecs_api_service_name" {
  description = "Name of the ECS API service (Used for ECS Exec)"
  value       = aws_ecs_service.terra_ecs_service_api.name
}

output "ecs_front_service_name" {
  description = "Name of the ECS front-end service (Used for ECS Exec)"
  value       = aws_ecs_service.terra_ecs_service_front.name
}

output "ecs_api_container_name" {
  description = "Name of the ECS API container (Used for ECS Exec)"
  value       = "api-python"
}

output "ecs_front_container_name" {
  description = "Name of the ECS front-end container (Used for ECS Exec)"
  value       = "front-nginx"
}

output "ecs_api_task_definition_arn" {
  description = "ARN of the ECS API task definition (Used for GitHub Actions)"
  value       = aws_ecs_task_definition.terra_ecs_task_definition_api.arn
}

output "ecs_front_task_definition_arn" {
  description = "ARN of the ECS front-end task definition (Used for GitHub Actions)"
  value       = aws_ecs_task_definition.terra_ecs_task_definition_front.arn
} 

output "ecs_db_initdata_task_definition_arn" {
  description = "ARN of the ECS DB initialization task definition (Used for GitHub Actions)"
  value       = aws_ecs_task_definition.terra_ecs_task_definition_db_initdata.arn
}

output "ecs_db_inituser_task_definition_arn" {
  description = "ARN of the ECS DB user creation task definition (Used for GitHub Actions)"
  value       = aws_ecs_task_definition.terra_ecs_task_definition_db_inituser.arn
}