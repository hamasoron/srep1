# アウトプットの定義
## ACM
output "acm_certificate_arn" {
  description = "ACM証明書のARN"
  value       = aws_acm_certificate.terra_acm_certificate.arn
}