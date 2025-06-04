# アウトプットの定義
## ACM
output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate (used for setting certificates in the ALB module)."
  value       = aws_acm_certificate.terra_acm_certificate.arn
}