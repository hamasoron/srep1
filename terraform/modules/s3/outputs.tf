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