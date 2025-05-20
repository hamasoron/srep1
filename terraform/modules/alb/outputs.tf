# アウトプットの定義
## ALB
output "alb_dns_name" {
  description = "ALBのDNS名（Route53 RecordsモジュールでAliasレコードを作成する際に使用）"
  value       = aws_lb.terra_alb.dns_name
}

output "alb_zone_id" {
  description = "ALBのゾーンID（Route53 RecordsモジュールでAliasレコードを作成する際に使用）"
  value       = aws_lb.terra_alb.zone_id
}

output "alb_front_target_group_arn" {
  description = "フロントエンドターゲットグループのARN（ECSモジュールで使用）"
  value       = aws_lb_target_group.terra_front_target_group.arn
}