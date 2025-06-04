# EventBridge ルール
resource "aws_cloudwatch_event_rule" "main" {
  count = var.enable_eventbridge ? 1 : 0
  
  name        = var.rule_name != "" ? var.rule_name : "${var.system_name}-${var.environment_name}-eventbridge-rule"
  description = var.rule_description
  state       = var.state

  # イベントパターンまたはスケジュール式のどちらかを設定
  event_pattern       = var.event_pattern != "" ? var.event_pattern : null
  schedule_expression = var.schedule_expression != "" ? var.schedule_expression : null

  tags = merge(
    var.tags,
    {
      Name        = var.rule_name != "" ? var.rule_name : "${var.system_name}-${var.environment_name}-eventbridge-rule"
      SystemName  = var.system_name
      Environment = var.environment_name
    }
  )
}

# EventBridge ターゲット
resource "aws_cloudwatch_event_target" "targets" {
  count = var.enable_eventbridge ? length(var.targets) : 0
  
  rule      = aws_cloudwatch_event_rule.main[0].name
  target_id = var.targets[count.index].target_id
  arn       = var.targets[count.index].arn

  # 入力データの変換
  input = var.targets[count.index].input

  dynamic "input_transformer" {
    for_each = var.targets[count.index].input_transformer != null ? [1] : []
    content {
      input_paths = var.targets[count.index].input_transformer.input_paths_map
      input_template = var.targets[count.index].input_transformer.input_template
    }
  }
} 