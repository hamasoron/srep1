# リソースの定義
## VPC Flow Logs（S3出力のみ）
resource "aws_flow_log" "terra_flow_log" {
  count                    = var.enable_vpc_flow_logs ? 1 : 0
  vpc_id                  = var.vpc_id
  log_destination_type    = "s3"
  log_destination         = var.s3_vpc_flow_logs_bucket_arn
  ### S3一択。CloudWatch Logsは使わない。（Kinesis Data Firehoseは置いていてCloudWatch LogsかS3のどちらがいいか論争）
  #### VPC Flow Logsの性質上NWトラフィックは容量が重くなりやすい（CloudWatch Logsは取り込み量高い）
  #### リアルタイム性はアプリケーションログと比べて低い（CloudWatch Logsである必要性がない）
  traffic_type            = var.traffic_type
  max_aggregation_interval = var.max_aggregation_interval
  log_format              = var.log_format
  destination_options {
    file_format = var.destination_options.file_format
    hive_compatible_partitions = var.destination_options.hive_compatible_partitions
    per_hour_partition = var.destination_options.per_hour_partition
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-vpc-flow-log"
  }
} 