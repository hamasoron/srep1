# アウトプットの定義
## Route53
output "route53_alias_record_fqdn" {
  description = "AliasレコードのFQDN"
  value       = aws_route53_record.terra_route53_record_alias.name
}