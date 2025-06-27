# リソースの定義
## CloudFormation StackSet（GuardDuty用）の作成
resource "aws_cloudformation_stack_set" "terra_cloudformation_stack_set_guardduty" {
  name                    = "${var.system_name}-${var.environment_name}-guardduty-stackset"
  description             = "Enable Amazon GuardDuty across all regions"
  administration_role_arn = var.cloudformation_stack_set_administration_role_arn
  execution_role_name     = var.cloudformation_stack_set_execution_role_name
  template_body           = file("${path.module}/templates/enable-guardduty-template.yml")
  ### CloudFormation Templateのデフォルトパラメータ
  parameters = {
    #### GuardDuty全般
    FindingPublishingFrequency = var.finding_publishing_frequency
    #### 保護プラン
    EBSMalwareProtection       = var.ebs_malware_protection
    EKSAuditLogs               = var.eks_audit_logs
    LambdaProtection           = var.lambda_protection
    RDSProtection              = var.rds_protection
    S3Protection               = var.s3_protection
    RuntimeMonitoring          = var.runtime_monitoring
  }
  ### デプロイメントオプション
  operation_preferences {
    max_concurrent_count    = var.max_concurrent_count
    failure_tolerance_count = var.failure_tolerance_count
    region_concurrency_type = var.region_concurrency_type
  }
  ### 機能管理をAWSに任せるかどうか
  managed_execution {
    active = false
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-GuardDuty-StackSet"
  }
}

## CloudFormation StackSet Instances（GuardDuty用）の作成
resource "aws_cloudformation_stack_set_instance" "terra_cloudformation_stack_set_instance_guardduty" {
  for_each       = toset(var.target_regions)
  region         = each.value
  stack_set_name = aws_cloudformation_stack_set.terra_cloudformation_stack_set_guardduty.name
  retain_stack    = var.retain_stack
  depends_on = [aws_cloudformation_stack_set.terra_cloudformation_stack_set_guardduty]
}