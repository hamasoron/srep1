# アウトプットの定義
## ACM
output "certificate_arn" {
  description = "ACM証明書のARN（ALBモジュールやCloudFrontモジュールなどで証明書を設定する際に使用）"
  value       = aws_acm_certificate.terra_acm_certificate.arn
}