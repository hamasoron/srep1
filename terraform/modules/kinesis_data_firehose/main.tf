# リソースの定義
## Kinesis Data Firehose配信ストリームの作成
resource "aws_kinesis_firehose_delivery_stream" "main" {
  for_each = var.delivery_streams
  
  name        = each.value.name
  destination = each.value.destination
  
  dynamic "extended_s3_configuration" {
    for_each = each.value.destination == "extended_s3" ? [each.value] : []
    content {
      role_arn   = extended_s3_configuration.value.role_arn
      bucket_arn = extended_s3_configuration.value.bucket_arn
      prefix     = extended_s3_configuration.value.prefix
      
      # 圧縮設定
      compression_format = extended_s3_configuration.value.compression_format
      
      # S3バックアップ設定
      dynamic "s3_backup_configuration" {
        for_each = extended_s3_configuration.value.enable_s3_backup ? [1] : []
        content {
          role_arn   = extended_s3_configuration.value.role_arn
          bucket_arn = extended_s3_configuration.value.bucket_arn
          prefix     = "${extended_s3_configuration.value.prefix}backup/"
        }
      }
      
      # CloudWatch Logging設定
      dynamic "cloudwatch_logging_options" {
        for_each = extended_s3_configuration.value.enable_cloudwatch_logging ? [1] : []
        content {
          enabled         = true
          log_group_name  = extended_s3_configuration.value.cloudwatch_log_group_name
          log_stream_name = extended_s3_configuration.value.cloudwatch_log_stream_name
        }
      }
    }
  }
  
  tags = merge(var.tags, each.value.tags)
} 