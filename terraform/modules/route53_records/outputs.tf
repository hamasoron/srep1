# アウトプットの定義
## Route53 Records
output "route53_records_alias_record_fqdn" {
  description = "AliasレコードのFQDN（ブラウザでALBのDNS名の別名アクセスする際に使用）"
  value       = aws_route53_record.terra_route53_record_alias.name
}