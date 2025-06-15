# アウトプットの定義
## ALB
output "alb_dns_name" {
  description = "DNS name of the ALB (used by Route53 Records module to create Alias records)"
  value       = aws_lb.terra_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB (used by Route53 Records module to create Alias records)"
  value       = aws_lb.terra_alb.zone_id
}

output "alb_front_target_group_arn" {
  description = "ARN of the front target group (used by ECS module)"
  value       = aws_lb_target_group.terra_front_target_group.arn
}