# アウトプットの定義
## Route53_zone
output "route53_zone_id" {
  description = "ID of the created Route53 hosted zone (used for domain validation in the ACM module)."
  value       = aws_route53_zone.terra_route53_zone.zone_id
}

output "route53_zone_name" {
  description = "Name of the created Route53 hosted zone (used as the domain name for certificates in the ACM module)."
  value       = aws_route53_zone.terra_route53_zone.name
}

output "route53_zone_name_servers" {
  description = "Name servers of the created Route53 hosted zone (used when copying NS records to external registrars)."
  value       = aws_route53_zone.terra_route53_zone.name_servers
}
