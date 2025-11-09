# リソースの定義
## Amazon Q DeveloperのSlack設定を作成（事前にコンソールにてAmazon Q DeveloperとSlackワークスペースを連携させる必要あり）
resource "aws_chatbot_slack_channel_configuration" "terra_q_developer_slack_channel_configuration" {
  configuration_name = "${var.system_name}-${var.environment_name}-q_developer-guardduty-slack"
  iam_role_arn      = var.iam_role_arn
  sns_topic_arns = [var.sns_topic_arn]
  slack_channel_id  = var.slack_channel_id
  slack_team_id     = var.slack_team_id
  logging_level = var.logging_level ##### CloudWatch Logsに通知するレベルを設定
  user_authorization_required = var.user_authorization_required
  tags = {
    Name = "${var.system_name}-${var.environment_name}-q_developer-guardduty-slack"
  }
} 