# アウトプットの定義
output "waf_webacl_id" {
  description = "ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.terra_wafv2_web_acl.id
}

output "waf_webacl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.terra_wafv2_web_acl.arn
}

output "waf_webacl_name" {
  description = "Name of the WAF Web ACL"
  value       = aws_wafv2_web_acl.terra_wafv2_web_acl.name
} 