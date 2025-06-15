# アウトプットの定義
## CloudTrail
output "cloudtrail_management_trail_arn" {
  description = "ARN of the CloudTrail management trail"
  value       = length(aws_cloudtrail.terra_cloudtrail_management) > 0 ? aws_cloudtrail.terra_cloudtrail_management[0].arn : null
}

output "cloudtrail_data_trail_arn" {
  description = "ARN of the CloudTrail data trail (only if created)"
  value       = length(aws_cloudtrail.terra_cloudtrail_data) > 0 ? aws_cloudtrail.terra_cloudtrail_data[0].arn : null
}

output "cloudtrail_insight_trail_arn" {
  description = "ARN of the CloudTrail insight trail (only if created)"
  value       = length(aws_cloudtrail.terra_cloudtrail_insight) > 0 ? aws_cloudtrail.terra_cloudtrail_insight[0].arn : null
}