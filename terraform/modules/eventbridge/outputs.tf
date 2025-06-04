# アウトプットの定義
## EventBridge ルール
output "eventbridge_rule_name" {
  description = "EventBridgeルールの名前"
  value       = var.enable_eventbridge ? aws_cloudwatch_event_rule.main[0].name : null
}

output "eventbridge_rule_arn" {
  description = "EventBridgeルールのARN"
  value       = var.enable_eventbridge ? aws_cloudwatch_event_rule.main[0].arn : null
}

output "eventbridge_rule_id" {
  description = "EventBridgeルールのID"
  value       = var.enable_eventbridge ? aws_cloudwatch_event_rule.main[0].id : null
}

output "eventbridge_rule_state" {
  description = "EventBridgeルールの状態"
  value       = var.enable_eventbridge ? aws_cloudwatch_event_rule.main[0].state : null
}

output "eventbridge_rule_description" {
  description = "EventBridgeルールの説明"
  value       = var.enable_eventbridge ? aws_cloudwatch_event_rule.main[0].description : null
}

## EventBridge ターゲット
output "eventbridge_targets" {
  description = "EventBridgeターゲットの情報"
  value = var.enable_eventbridge ? [
    for i, target in aws_cloudwatch_event_target.targets : {
      target_id = target.target_id
      arn       = target.arn
      rule      = target.rule
    }
  ] : []
} 