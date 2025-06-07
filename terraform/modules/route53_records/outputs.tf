# アウトプットの定義
## Route53 Records
output "route53_records_alias_record_fqdn" {
  description = "Alias record FQDN (used to access the ALB's DNS name as an alias in the browser)"
  value       = aws_route53_record.terra_route53_record_alias.name
}