# output "web_acl_id" {
#   description = "WAF Web ACLのID"
#   value       = aws_wafv2_web_acl.main.id
# }

# output "web_acl_arn" {
#   description = "WAF Web ACLのARN"
#   value       = aws_wafv2_web_acl.main.arn
# }

# output "web_acl_name" {
#   description = "WAF Web ACLの名前"
#   value       = aws_wafv2_web_acl.main.name
# }

# output "waf_logs_bucket_name" {
#   description = "WAFログ用S3バケット名"
#   value       = var.enable_logging ? aws_s3_bucket.waf_logs[0].bucket : null
# }

# output "waf_logs_bucket_arn" {
#   description = "WAFログ用S3バケットのARN"
#   value       = var.enable_logging ? aws_s3_bucket.waf_logs[0].arn : null
# }

# output "firehose_delivery_stream_arn" {
#   description = "Kinesis Firehose配信ストリームのARN"
#   value       = var.enable_logging ? aws_kinesis_firehose_delivery_stream.waf_logs[0].arn : null
# } 