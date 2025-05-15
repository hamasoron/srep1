# アウトプットの定義
output "contents_bucket_name" {
  description = "コンテンツバケットの名前"
  value       = aws_s3_bucket.terra_s3_bucket["contents"].id
}

output "contents_bucket_arn" {
  description = "コンテンツバケットのARN"
  value       = aws_s3_bucket.terra_s3_bucket["contents"].arn
}

output "alb_logs_bucket_name" {
  description = "ALBログバケットの名前"
  value       = aws_s3_bucket.terra_s3_bucket["alb_logs"].id
}

output "alb_logs_bucket_arn" {
  description = "ALBログバケットのARN"
  value       = aws_s3_bucket.terra_s3_bucket["alb_logs"].arn
}

# すべてのバケット情報をマップとして出力（拡張性のため）
output "bucket_names" {
  description = "作成されたすべてのS3バケット名"
  value       = { for k, v in aws_s3_bucket.terra_s3_bucket : k => v.id }
}

output "bucket_arns" {
  description = "作成されたすべてのS3バケットARN"
  value       = { for k, v in aws_s3_bucket.terra_s3_bucket : k => v.arn }
} 
