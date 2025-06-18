# アウトプットの定義
## S3
output "s3_app_contents_bucket_name" {
  description = "name of the app contents bucket"
  value       = aws_s3_bucket.terra_s3_bucket["app_contents"].id
}

output "s3_alb_logs_bucket_name" {
  description = "name of the alb logs bucket (used by ALB module to save access logs and connection logs)"
  value       = aws_s3_bucket.terra_s3_bucket["alb_logs"].id
}

output "s3_cloudtrail_logs_bucket_name" {
  description = "name of the cloudtrail logs bucket (used by CloudTrail module to save logs)"
  value       = aws_s3_bucket.terra_s3_bucket["cloudtrail_logs"].id
}

output "s3_vpc_flow_logs_bucket_arn" {
  description = "ARN of the vpc flow logs bucket (used by VPC Flow Logs module to save logs)"
  value       = aws_s3_bucket.terra_s3_bucket["vpc_flow_logs"].arn
}

output "s3_waf_logs_bucket_arn" {
  description = "ARN of the waf logs bucket (used by WAF module to save logs)"
  value       = aws_s3_bucket.terra_s3_bucket["waf_logs"].arn
}