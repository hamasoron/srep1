# アウトプットの定義
## ECS
output "ecs_cluster_id" {
  description = "ECSクラスターのID"
  value       = aws_ecs_cluster.terra_ecs_cluster.id
}

output "ecs_cluster_name" {
  description = "ECSクラスターの名前"
  value       = aws_ecs_cluster.terra_ecs_cluster.name
}

output "ecs_api_service_id" {
  description = "ECS APIサービスのID"
  value       = aws_ecs_service.terra_ecs_service_api.id
}

output "ecs_api_service_name" {
  description = "ECS APIサービスの名前"
  value       = aws_ecs_service.terra_ecs_service_api.name
}

output "ecs_front_service_id" {
  description = "ECS フロントエンドサービスのID"
  value       = aws_ecs_service.terra_ecs_service_front.id
}

output "ecs_front_service_name" {
  description = "ECS フロントエンドサービスの名前"
  value       = aws_ecs_service.terra_ecs_service_front.name
}

output "ecs_api_task_definition_arn" {
  description = "ECS APIタスク定義のARN"
  value       = aws_ecs_task_definition.terra_ecs_task_definition_api.arn
}

output "ecs_front_task_definition_arn" {
  description = "ECS フロントエンドタスク定義のARN"
  value       = aws_ecs_task_definition.terra_ecs_task_definition_front.arn
} 