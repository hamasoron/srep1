# アウトプットの定義
## CloudMap
output "cloudmap_service_arn" {
  description = "ARN of the CloudMap service (used in the ECS module)"
  value       = aws_service_discovery_service.terra_service_discovery_service.arn
}