# アウトプットの定義
## CloudTrail
output "cloudtrail_management_trail_arn" {
  description = "CloudTrailの管理証跡のARN"
  value       = length(aws_cloudtrail.terra_cloudtrail_management) > 0 ? aws_cloudtrail.terra_cloudtrail_management[0].arn : null
}

output "cloudtrail_data_trail_arn" {
  description = "CloudTrailのデータ証跡のARN（作成された場合のみ）"
  value       = length(aws_cloudtrail.terra_cloudtrail_data) > 0 ? aws_cloudtrail.terra_cloudtrail_data[0].arn : null
}

output "cloudtrail_insight_trail_arn" {
  description = "CloudTrailのインサイト証跡のARN（作成された場合のみ）"
  value       = length(aws_cloudtrail.terra_cloudtrail_insight) > 0 ? aws_cloudtrail.terra_cloudtrail_insight[0].arn : null
}
