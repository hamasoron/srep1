# # データソース
# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}

# # Lambda実行用IAMロール
# resource "aws_iam_role" "lambda_execution_role" {
#   count = var.create_lambda ? 1 : 0
  
#   name = var.function_name != "" ? "${var.function_name}-role" : "${var.system_name}-${var.environment_name}-slack-lambda-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = merge(
#     var.tags,
#     {
#       Name        = var.function_name != "" ? "${var.function_name}-role" : "${var.system_name}-${var.environment_name}-slack-lambda-role"
#       SystemName  = var.system_name
#       Environment = var.environment_name
#     }
#   )
# }

# # Lambda実行用IAMポリシー
# data "aws_iam_policy_document" "lambda_policy" {
#   count = var.create_lambda ? 1 : 0
  
#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents"
#     ]
#     resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
#   }

#   # デッドレターキューがある場合の権限
#   dynamic "statement" {
#     for_each = var.dead_letter_config_target_arn != "" ? [1] : []
#     content {
#       effect = "Allow"
#       actions = [
#         "sqs:SendMessage"
#       ]
#       resources = [var.dead_letter_config_target_arn]
#     }
#   }
# }

# resource "aws_iam_policy" "lambda_policy" {
#   count = var.create_lambda ? 1 : 0
  
#   name   = var.function_name != "" ? "${var.function_name}-policy" : "${var.system_name}-${var.environment_name}-slack-lambda-policy"
#   policy = data.aws_iam_policy_document.lambda_policy[0].json

#   tags = merge(
#     var.tags,
#     {
#       Name        = var.function_name != "" ? "${var.function_name}-policy" : "${var.system_name}-${var.environment_name}-slack-lambda-policy"
#       SystemName  = var.system_name
#       Environment = var.environment_name
#     }
#   )
# }

# resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
#   count = var.create_lambda ? 1 : 0
  
#   role       = aws_iam_role.lambda_execution_role[0].name
#   policy_arn = aws_iam_policy.lambda_policy[0].arn
# }

# # Lambda関数のZIPファイル作成
# data "archive_file" "lambda_zip" {
#   count = var.create_lambda ? 1 : 0
  
#   type        = "zip"
#   output_path = "${path.module}/slack_notification.zip"
#   source {
#     content = templatefile("${path.module}/slack_notification.py", {
#       slack_webhook_url = var.slack_webhook_url
#       slack_channel     = var.slack_channel
#       slack_username    = var.slack_username
#       slack_icon_emoji  = var.slack_icon_emoji
#     })
#     filename = "lambda_function.py"
#   }
# }

# # Lambda関数
# resource "aws_lambda_function" "slack_notification" {
#   count = var.create_lambda ? 1 : 0
  
#   filename         = data.archive_file.lambda_zip[0].output_path
#   function_name    = var.function_name != "" ? var.function_name : "${var.system_name}-${var.environment_name}-slack-notification"
#   role            = aws_iam_role.lambda_execution_role[0].arn
#   handler         = "lambda_function.lambda_handler"
#   source_code_hash = data.archive_file.lambda_zip[0].output_base64sha256
#   runtime         = var.lambda_runtime
#   timeout         = var.lambda_timeout
#   memory_size     = var.lambda_memory_size
#   description     = var.lambda_description
  
#   reserved_concurrent_executions = var.reserved_concurrent_executions != -1 ? var.reserved_concurrent_executions : null

#   environment {
#     variables = merge(
#       {
#         SLACK_WEBHOOK_URL = var.slack_webhook_url
#         SLACK_CHANNEL     = var.slack_channel
#         SLACK_USERNAME    = var.slack_username
#         SLACK_ICON_EMOJI  = var.slack_icon_emoji
#       },
#       var.additional_environment_variables
#     )
#   }

#   # デッドレターキューの設定
#   dynamic "dead_letter_config" {
#     for_each = var.dead_letter_config_target_arn != "" ? [1] : []
#     content {
#       target_arn = var.dead_letter_config_target_arn
#     }
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name        = var.function_name != "" ? var.function_name : "${var.system_name}-${var.environment_name}-slack-notification"
#       SystemName  = var.system_name
#       Environment = var.environment_name
#     }
#   )
# }

# # Lambda関数のCloudWatch Logs
# resource "aws_cloudwatch_log_group" "lambda_logs" {
#   count = var.create_lambda ? 1 : 0
  
#   name              = "/aws/lambda/${aws_lambda_function.slack_notification[0].function_name}"
#   retention_in_days = var.log_retention_in_days

#   tags = merge(
#     var.tags,
#     {
#       Name        = "${aws_lambda_function.slack_notification[0].function_name}-logs"
#       SystemName  = var.system_name
#       Environment = var.environment_name
#     }
#   )
# } 