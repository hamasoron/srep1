# アウトプットの定義
## ALB
output "alb_arn" {
  description = "ALBのARN"
  value       = aws_lb.terra_alb.arn
}

output "alb_dns_name" {
  description = "ALBのDNS名"
  value       = aws_lb.terra_alb.dns_name
}

output "front_target_group_arn" {
  description = "フロントエンドターゲットグループのARN"
  value       = aws_lb_target_group.terra_front_target_group.arn
}

output "front_target_group_name" {
  description = "フロントエンドターゲットグループの名前"
  value       = aws_lb_target_group.terra_front_target_group.name
} 