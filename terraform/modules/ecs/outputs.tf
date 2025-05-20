# アウトプットの定義
## ECS
output "ecs_cluster_id" {
  description = "ECSクラスターのID（GitHub Actionsで使用）"
  value       = aws_ecs_cluster.terra_ecs_cluster.id
}

output "ecs_cluster_name" {
  description = "ECSクラスターの名前（ECS Exec等で使用）"
  value       = aws_ecs_cluster.terra_ecs_cluster.name
}

output "ecs_api_service_name" {
  description = "ECS APIサービスの名前（ECS Exec等で使用）"
  value       = aws_ecs_service.terra_ecs_service_api.name
}

output "ecs_front_service_name" {
  description = "ECS フロントエンドサービスの名前（ECS Exec等で使用）"
  value       = aws_ecs_service.terra_ecs_service_front.name
}

output "ecs_api_container_name" {
  description = "ECS APIコンテナの名前（ECS Exec等で使用）"
  value       = aws_ecs_task_definition.terra_ecs_task_definition_api.container_definitions
}

output "ecs_front_container_name" {
  description = "ECS フロントエンドコンテナの名前（ECS Exec等で使用）"
  value       = aws_ecs_task_definition.terra_ecs_task_definition_front.container_definitions
}

output "ecs_api_task_definition_arn" {
  description = "ECS APIタスク定義のARN（GitHub Actionsで使用）"
  value       = aws_ecs_task_definition.terra_ecs_task_definition_api.arn
}

output "ecs_front_task_definition_arn" {
  description = "ECS フロントエンドタスク定義のARN（GitHub Actionsで使用）"
  value       = aws_ecs_task_definition.terra_ecs_task_definition_front.arn
} 

output "ecs_db_initdata_task_definition_arn" {
  description = "ECS データ投入用タスク定義のARN（GitHub Actionsで使用）"
  value       = aws_ecs_task_definition.terra_ecs_task_definition_db_initdata.arn
}

output "ecs_db_inituser_task_definition_arn" {
  description = "ECS DBユーザー作成用タスク定義のARN（GitHub Actionsで使用）"
  value       = aws_ecs_task_definition.terra_ecs_task_definition_db_inituser.arn
}