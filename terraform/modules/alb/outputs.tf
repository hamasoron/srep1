output "alb_arn" {
  description = "ALBのARN"
  value       = aws_lb.terra_alb.arn
}

output "alb_dns_name" {
  description = "ALBのDNS名"
  value       = aws_lb.terra_alb.dns_name
}

output "target_group_arn" {
  description = "ターゲットグループのARN"
  value       = aws_lb_target_group.terra_target_group.arn
}

output "target_group_name" {
  description = "ターゲットグループの名前"
  value       = aws_lb_target_group.terra_target_group.name
} 