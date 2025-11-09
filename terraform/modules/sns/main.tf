# データソースの定義
## AWSアカウントIDを取得
data "aws_caller_identity" "current" {}

# ローカル変数の定義
locals {
  ## EventBridgeからのアクセス許可
  eventbridge_statement = [{
    Sid = "AllowEventBridgePublish"
    Effect = "Allow"
    Principal = {
      Service = "events.amazonaws.com"
    }
    Action = "sns:Publish"
    Resource = aws_sns_topic.terra_sns_topic_guardduty.arn
  }]
  ## Amazon Q Developerからのアクセス許可
  q_developer_statement = [{
    Sid = "AllowChatbotSubscribe"
    Effect = "Allow"
    Principal = {
      Service = "chatbot.amazonaws.com"
    }
    Action = "sns:Subscribe"
    Resource = aws_sns_topic.terra_sns_topic_guardduty.arn
    Condition = {
      StringEquals = {
        "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
      }
    }
  }]
  final_policy_document = {
    Version = "2012-10-17"
    Statement = concat(local.eventbridge_statement, local.q_developer_statement)
  }
}

# リソースの定義
## SNSトピックを作成
resource "aws_sns_topic" "terra_sns_topic_guardduty" {
  name         = "${var.system_name}-${var.environment_name}-sns-guardduty-topic"
  display_name = "${var.system_name}-${var.environment_name}-sns-guardduty-topic"
  ### 暗号化設定
  # kms_master_key_id = "alias/aws/sns"  ##### いったん無効化
  ### 基本的な配信ポリシー（Amazon Q Developer向け）
  delivery_policy = jsonencode({
    http = {
      defaultHealthyRetryPolicy = {
        minDelayTarget     = 20 ##### リトライ時の最小遅延時間（秒）。今回の場合は必ず20秒後にリトライ。
        maxDelayTarget     = 20 ##### リトライ時の最大遅延時間（秒）。今回の場合は必ず20秒後にリトライ。
        numRetries         = var.max_delivery_attempts ##### リトライの最大回数
        numMaxDelayRetries = 0 ##### 最大遅延でリトライする回数
        numMinDelayRetries = 0 ##### 最小遅延でリトライする回数
        numNoDelayRetries  = 0 ##### 遅延なしでリトライする回数
        backoffFunction    = "linear" ##### リトライ間隔の増加方式
      }
      disableSubscriptionOverrides = true ##### サブスクリプション側で配信ポリシーの上書きを無効
    }
  })
  tags = {
    Name = "${var.system_name}-${var.environment_name}-sns-guardduty-topic"
  }
}

## SNSトピックのアクセスポリシーを作成（EventBridgeやAmazon Q Developerからのアクセス許可）
resource "aws_sns_topic_policy" "terra_sns_topic_policy_guardduty" {
  arn   = aws_sns_topic.terra_sns_topic_guardduty.arn
  policy = jsonencode(local.final_policy_document)
  depends_on = [ aws_sns_topic.terra_sns_topic_guardduty ]
}