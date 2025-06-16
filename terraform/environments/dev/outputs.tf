# アウトプットの定義
## Route53 Zone
output "route53_zone_id" {
  description = "ID of the created Route53 hosted zone (used for domain validation in the ACM module)."
  value = module.route53_zone.route53_zone_id
}

output "route53_zone_name" {
  description = "Name of the created Route53 hosted zone (used as the domain name for certificates in the ACM module)."
  value = module.route53_zone.route53_zone_name
}

output "route53_zone_name_servers" {
  description = "Name servers of the created Route53 hosted zone (used when copying NS records to external registrars)."
  value = module.route53_zone.route53_zone_name_servers
}

## ACM
output "acm_certificate_arn" {
  description = "ARN of the ACM certificate (used in ALB module, etc.)"
  value = module.acm.acm_certificate_arn
}

## VPC
output "vpc_create_protected_ngw_associations" {
  description = "Whether to create protected subnet and NAT gateway association (used in ECS module)."
  value = module.vpc.vpc_create_protected_ngw_associations
}

output "vpc_nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value = module.vpc.vpc_nat_gateway_ids
}

output "vpc_id" {
  description = "ID of the VPC (used in SG, ALB module, etc.)"
  value = module.vpc.vpc_id
}

output "vpc_public_subnet_ids" {
  description = "ID of the public subnet (always get the ID of the public subnet that changes dynamically according to the AZ and NAT configuration. Used in ALB module, etc.)"
  value = module.vpc.vpc_public_subnet_ids
}

output "vpc_private_subnet_ids" {
  description = "ID of the private subnet (always get the ID of the private subnet that changes dynamically according to the AZ and NAT configuration. Used in RDS module, etc.)"
  value = module.vpc.vpc_private_subnet_ids
}

output "vpc_protected_subnet_ids" {
  description = "ID of the protected subnet (always get the ID of the protected subnet that changes dynamically according to the AZ and NAT configuration. Used in RDS module, etc.)"
  value = module.vpc.vpc_protected_subnet_ids
}

output "vpc_route_table_ids" {
  description = "ID of the route table"
  value = module.vpc.vpc_route_table_ids
}

output "vpc_available_azs_names" {
  description = "List of actual AZ names used in VPC subnet configuration (used in RDS module for dynamic AZ mapping)"
  value = module.vpc.vpc_available_azs_names
}

## SG
output "sg_security_group_ids" {
  description = "IDs of security groups (used by RDS, Lambda, ALB, ECS, CloudShell etc.)"
  value = module.sg.sg_security_group_ids
}

## IAM Role
output "iam_role_ecs_task_role_arn" {
  description = "ARN of the ECS task role (used by ECS module.)"
  value = module.iam_role.iam_role_ecs_task_role_arn
}
  
output "iam_role_ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role (used by ECS module.)"
  value = module.iam_role.iam_role_ecs_task_execution_role_arn
}

output "iam_role_lambda_master_rotation_arn" {
  description = "ARN of the master user Lambda function role (used by Lambda module.)"
  value = module.iam_role.iam_role_lambda_master_rotation_arn
}

output "iam_role_lambda_app_rotation_arn" {
  description = "ARN of the app user Lambda function role (used by Lambda module.)"
  value = module.iam_role.iam_role_lambda_app_rotation_arn
}

output "iam_role_github_actions_role_arn" {
  description = "ARN of the GitHub Actions role (used for copying to AWS_ROLE_TO_ASSUME in GitHub Secrets and Variables)"
  value = module.iam_role.iam_role_github_actions_role_arn
}

## IAM AccessAnalyzer
output "iam_accessanalyzer_arn" {
  description = "ARN of the IAM AccessAnalyzer"
  value = module.iam_accessanalyzer.iam_accessanalyzer_arn
}

## CloudWatch Logs
output "rds_log_group_names" {
  description = "Map of CloudWatch log group names (used by RDS module)"
  value = module.cloudwatch_logs.rds_log_group_names
}

output "ecs_log_group_names" {
  description = "Map of CloudWatch log group names (used by ECS module)"
  value = module.cloudwatch_logs.ecs_log_group_names
}

output "lambda_log_group_names" {
  description = "Map of CloudWatch log group names (used by Lambda module)"
  value = module.cloudwatch_logs.lambda_log_group_names
}

## Secrets Manager
output "secretsmanager_secret_arns" {
  description = "Map of secret ARNs (used by Lambda module for secret-related settings)"
  value = module.secretsmanager.secretsmanager_secret_arns
}

output "secretsmanager_master_credentials_json" {
  description = "Master user credentials (used by RDS module for master_username and master_password)"
  value = module.secretsmanager.secretsmanager_master_credentials_json
  sensitive = true
}

## RDS
output "rds_cluster_id" {
  description = "ID of the Aurora cluster"
  value = module.rds.rds_cluster_id
}

output "rds_cluster_writer_endpoint" {
  description = "Writer endpoint of the Aurora cluster (used in ECS module.)"
  value = module.rds.rds_cluster_writer_endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster (used in ECS module.)"
  value = module.rds.rds_cluster_reader_endpoint
}

output "rds_cluster_port" {
  description = "Port number of the Aurora cluster (used in Lambda module, ECS module.)"
  value = module.rds.rds_cluster_port
}

output "rds_cluster_database_name" {
  description = "Default database name of the Aurora cluster (used in ECS module.)"
  value = module.rds.rds_cluster_database_name
}

output "rds_cluster_instance_details" {
  description = "Detailed information of the Aurora instances (ID, AZ, role)"
  value = module.rds.rds_cluster_instance_details
}

output "rds_cluster_identifier" {
  description = "Identifier of the Aurora cluster (used in Lambda module for master user rotation only. Not used for app user rotation.)"
  value = module.rds.rds_cluster_identifier
}

## Lambda
output "lambda_master_function_arn" {
  description = "ARN of the Lambda function for the master user"
  value = module.lambda.lambda_master_function_arn
}

output "lambda_app_function_arn" {
  description = "ARN of the Lambda function for the app user"
  value = module.lambda.lambda_app_function_arn
}

## S3
output "s3_app_contents_bucket_name" {
  description = "name of the app contents bucket"
  value = module.s3.s3_app_contents_bucket_name
}

output "s3_alb_logs_bucket_name" {
  description = "name of the alb logs bucket (used by ALB module to save access logs and connection logs)"
  value = module.s3.s3_alb_logs_bucket_name
}

output "s3_cloudtrail_logs_bucket_name" {
  description = "name of the cloudtrail logs bucket (used by CloudTrail module to save logs)"
  value = module.s3.s3_cloudtrail_logs_bucket_name
}

output "s3_vpc_flow_logs_bucket_arn" {
  description = "ARN of the vpc flow logs bucket (used by VPC Flow Logs module to save logs)"
  value = module.s3.s3_vpc_flow_logs_bucket_arn
}

## ALB
output "alb_dns_name" {
  description = "DNS name of the ALB（used by Route53 Records module to create Alias records）"
  value = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB（used by Route53 Records module to create Alias records）"
  value = module.alb.alb_zone_id
}

output "alb_front_target_group_arn" {
  description = "ARN of the front target group (used by ECS module)"
  value = module.alb.alb_front_target_group_arn
}

## CloudTrail
output "cloudtrail_management_trail_arn" {
  description = "ARN of the CloudTrail management trail"
  value = module.cloudtrail.cloudtrail_management_trail_arn
}
output "cloudtrail_data_trail_arn" {
  description = "ARN of the CloudTrail data trail"
  value = module.cloudtrail.cloudtrail_data_trail_arn
}

output "cloudtrail_insight_trail_arn" {
  description = "ARN of the CloudTrail insight trail"
  value = module.cloudtrail.cloudtrail_insight_trail_arn
}

## VPC Flow Logs
output "vpc_flow_log_arn" {
  description = "ARN of the VPC Flow Log"
  value = module.vpc_flow_logs.vpc_flow_log_arn
}

## Route53 Records
output "route53_records_alias_record_fqdn" {
  description = "FQDN of the Alias record (used when accessing the ALB's DNS name as an alias in the browser)"
  value = module.route53_records.route53_records_alias_record_fqdn
}

## ECR
output "ecr_repository_urls" {
  description = "URL of the ECR repository (used as the image URL for the task definition in the ECS module)"
  value = module.ecr.ecr_repository_urls
}

## ECS
output "ecs_cluster_id" {
  description = "ECSクラスターのID（GitHub Actionsで使用）"
  value = module.ecs.ecs_cluster_id
}

output "ecs_cluster_name" {
  description = "ECSクラスターの名前（ECS Exec等で使用）"
  value = module.ecs.ecs_cluster_name
}

output "ecs_api_service_name" {
  description = "ECS APIサービスの名前（ECS Exec等で使用）"
  value = module.ecs.ecs_api_service_name
}

output "ecs_front_service_name" {
  description = "ECS フロントエンドサービスの名前（ECS Exec等で使用）"
  value = module.ecs.ecs_front_service_name
}

output "ecs_api_container_name" {
  description = "ECS APIコンテナの名前（ECS Exec等で使用）"
  value = module.ecs.ecs_api_container_name
}

output "ecs_front_container_name" {
  description = "ECS フロントエンドコンテナの名前（ECS Exec等で使用）"
  value = module.ecs.ecs_front_container_name
}

output "ecs_api_task_definition_arn" {
  description = "ECS APIタスク定義のARN（GitHub Actionsで使用）"
  value = module.ecs.ecs_api_task_definition_arn
}

output "ecs_front_task_definition_arn" {
  description = "ECS フロントエンドタスク定義のARN（GitHub Actionsで使用）"
  value = module.ecs.ecs_front_task_definition_arn
}

output "ecs_db_initdata_task_definition_arn" {
  description = "ECS データ投入用タスク定義のARN（GitHub Actionsで使用）"
  value = module.ecs.ecs_db_initdata_task_definition_arn
}

output "ecs_db_inituser_task_definition_arn" {
  description = "ECS DBユーザー作成用タスク定義のARN（GitHub Actionsで使用）"
  value = module.ecs.ecs_db_inituser_task_definition_arn
}
