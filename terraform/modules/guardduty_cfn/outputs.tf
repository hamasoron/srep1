# アウトプットの定義
## GuardDuty CFn
output "guardduty_cfn_stack_set_id" {
  description = "ID of the CloudFormation StackSet"
  value       = aws_cloudformation_stack_set.terra_cloudformation_stack_set_guardduty.id
}

output "guardduty_cfn_stack_set_name" {
  description = "Name of the CloudFormation StackSet"
  value       = aws_cloudformation_stack_set.terra_cloudformation_stack_set_guardduty.name
}

output "guardduty_cfn_stack_set_arn" {
  description = "ARN of the CloudFormation StackSet"
  value       = aws_cloudformation_stack_set.terra_cloudformation_stack_set_guardduty.arn
}

output "guardduty_cfn_enabled_regions" {
  description = "List of regions where GuardDuty is enabled"
  value       = var.target_regions
}