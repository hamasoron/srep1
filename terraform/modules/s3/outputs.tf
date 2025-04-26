# アウトプットの定義
output "alb_logs_bucket_name" {
  description = "ALBログバケットの名前"
  value       = aws_s3_bucket.terra_s3_bucket_alb_logs.id
}

output "alb_logs_bucket_arn" {
  description = "ALBログバケットのARN"
  value       = aws_s3_bucket.terra_s3_bucket_alb_logs.arn
} 