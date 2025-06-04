# アウトプットの定義
## S3
output "s3_app_contents_bucket_name" {
  description = "アプリケーションのコンテンツバケットの名前"
  value       = aws_s3_bucket.terra_s3_bucket["app_contents"].id
}

output "s3_alb_logs_bucket_name" {
  description = "ALBのログバケットの名前（ALBモジュールでアクセスログやコネクションログを保存するために使用）"
  value       = aws_s3_bucket.terra_s3_bucket["alb_logs"].id
}

output "s3_cloudtrail_logs_bucket_name" {
  description = "CloudTrailのログバケットの名前（CloudTrailモジュールでログを保存するために使用）"
  value       = aws_s3_bucket.terra_s3_bucket["cloudtrail_logs"].id
}

output "s3_vpc_flow_logs_bucket_name" {
  description = "VPC Flow Logsのログバケットの名前）"
  value       = aws_s3_bucket.terra_s3_bucket["vpc_flow_logs"].id
}

output "s3_vpc_flow_logs_bucket_arn" {
  description = "VPC Flow LogsのログバケットのARN（VPC Flow Logsモジュールでログを保存するために使用）"
  value       = aws_s3_bucket.terra_s3_bucket["vpc_flow_logs"].arn
}