# KMSキー（SNS暗号化用）
resource "aws_kms_key" "sns" {
  count = var.create_sns_topic && var.enable_encryption && var.create_kms_key ? 1 : 0
  
  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window_in_days

  tags = merge(
    var.tags,
    {
      Name        = "${var.system_name}-${var.environment_name}-sns-kms-key"
      SystemName  = var.system_name
      Environment = var.environment_name
    }
  )
}

resource "aws_kms_alias" "sns" {
  count = var.create_sns_topic && var.enable_encryption && var.create_kms_key ? 1 : 0
  
  name          = "alias/${var.system_name}-${var.environment_name}-sns-key"
  target_key_id = aws_kms_key.sns[0].key_id
}

# SNSトピック
resource "aws_sns_topic" "main" {
  count = var.create_sns_topic ? 1 : 0
  
  name         = var.topic_name != "" ? var.topic_name : "${var.system_name}-${var.environment_name}-sns-topic"
  display_name = var.display_name
  
  # 暗号化設定
  kms_master_key_id = var.enable_encryption ? (
    var.kms_master_key_id != "" ? var.kms_master_key_id : (
      var.create_kms_key ? aws_kms_key.sns[0].id : null
    )
  ) : null

  # ポリシー設定
  policy          = var.policy != "" ? var.policy : null
  delivery_policy = var.delivery_policy != "" ? var.delivery_policy : null

  # フィードバック設定
  application_failure_feedback_role_arn    = var.application_failure_feedback_role_arn != "" ? var.application_failure_feedback_role_arn : null
  application_success_feedback_role_arn    = var.application_success_feedback_role_arn != "" ? var.application_success_feedback_role_arn : null
  application_success_feedback_sample_rate = var.application_success_feedback_sample_rate
  
  http_failure_feedback_role_arn    = var.http_failure_feedback_role_arn != "" ? var.http_failure_feedback_role_arn : null
  http_success_feedback_role_arn    = var.http_success_feedback_role_arn != "" ? var.http_success_feedback_role_arn : null
  http_success_feedback_sample_rate = var.http_success_feedback_sample_rate

  tags = merge(
    var.tags,
    {
      Name        = var.topic_name != "" ? var.topic_name : "${var.system_name}-${var.environment_name}-sns-topic"
      SystemName  = var.system_name
      Environment = var.environment_name
    }
  )
} 