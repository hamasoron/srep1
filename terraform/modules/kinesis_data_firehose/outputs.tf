# アウトプットの定義
output "delivery_stream_arns" {
  description = "Map of Kinesis Firehose delivery stream ARNs"
  value = {
    for name, stream in aws_kinesis_firehose_delivery_stream.main : name => stream.arn
  }
}

output "delivery_stream_names" {
  description = "Map of Kinesis Firehose delivery stream names"
  value = {
    for name, stream in aws_kinesis_firehose_delivery_stream.main : name => stream.name
  }
}

output "delivery_stream_ids" {
  description = "Map of Kinesis Firehose delivery stream IDs"
  value = {
    for name, stream in aws_kinesis_firehose_delivery_stream.main : name => stream.id
  }
} 