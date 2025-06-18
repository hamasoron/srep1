# アウトプットの定義
output "web_acl_id" {
  description = "WAF Web ACLのID"
  value       = aws_wafv2_web_acl.terraform_waf_web_acl.id
}

output "web_acl_arn" {
  description = "WAF Web ACLのARN"
  value       = aws_wafv2_web_acl.terraform_waf_web_acl.arn
}

output "web_acl_name" {
  description = "WAF Web ACLの名前"
  value       = aws_wafv2_web_acl.terraform_waf_web_acl.name
} 