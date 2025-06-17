# # Kinesis Firehose用のIAMロール
# resource "aws_iam_role" "firehose_role" {
#   count = var.enable_logging ? 1 : 0
#   name  = "${var.system_name}-${var.environment_name}-firehose-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "firehose.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = var.tags
# }

# # Kinesis Firehose用のIAMポリシー
# resource "aws_iam_role_policy" "firehose_policy" {
#   count = var.enable_logging ? 1 : 0
#   name  = "${var.system_name}-${var.environment_name}-firehose-policy"
#   role  = aws_iam_role.firehose_role[0].id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:AbortMultipartUpload",
#           "s3:GetBucketLocation",
#           "s3:GetObject",
#           "s3:ListBucket",
#           "s3:ListBucketMultipartUploads",
#           "s3:PutObject"
#         ]
#         Resource = [
#           aws_s3_bucket.waf_logs[0].arn,
#           "${aws_s3_bucket.waf_logs[0].arn}/*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:PutLogEvents"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# } 