# アウトプットの定義
## ALB
output "alb_arn" {
  description = "ALBのARN"
  value       = aws_lb.terra_alb.arn
}

output "alb_dns_name" {
  description = "ALBのDNS名（Route53モジュールでエイリアスレコードを作成する際に使用）"
  value       = aws_lb.terra_alb.dns_name
}

output "alb_zone_id" {
  description = "ALBのゾーンID（Route53モジュールでエイリアスレコードを作成する際に使用）"
  value       = aws_lb.terra_alb.zone_id
}

output "http_listener_arn" {
  description = "HTTP リスナーのARN"
  value       = aws_lb_listener.terra_http_listener.arn
}

output "https_listener_arn" {
  description = "HTTPS リスナーのARN"
  value       = aws_lb_listener.terra_https_listener.arn
}

output "front_target_group_arn" {
  description = "フロントエンドターゲットグループのARN"
  value       = aws_lb_target_group.terra_front_target_group.arn
}

output "front_target_group_name" {
  description = "フロントエンドターゲットグループの名前"
  value       = aws_lb_target_group.terra_front_target_group.name
} 