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
  description = "The list of NAT Gateway IDs"
  value = module.vpc.vpc_nat_gateway_ids
}

output "vpc_id" {
  description = "The ID of the VPC (used in SG, ALB module, etc.)"
  value = module.vpc.vpc_id
}

output "vpc_public_subnet_ids" {
  description = "The ID of the public subnet (always get the ID of the public subnet that changes dynamically according to the AZ and NAT configuration. Used in ALB module, etc.)"
  value = module.vpc.vpc_public_subnet_ids
}

output "vpc_private_subnet_ids" {
  description = "The ID of the private subnet (always get the ID of the private subnet that changes dynamically according to the AZ and NAT configuration. Used in RDS module, etc.)"
  value = module.vpc.vpc_private_subnet_ids
}

output "vpc_protected_subnet_ids" {
  description = "The ID of the protected subnet (always get the ID of the protected subnet that changes dynamically according to the AZ and NAT configuration. Used in RDS module, etc.)"
  value = module.vpc.vpc_protected_subnet_ids
}

output "vpc_route_table_ids" {
  description = "The ID of the route table"
  value = module.vpc.vpc_route_table_ids
}

## SG
output "sg_security_group_ids" {
  description = "Security group IDs (used by RDS, Lambda, ALB, ECS, etc.)"
  value = module.sg.sg_security_group_ids
}

## IAM Role
output "iam_role_ecs_task_role_arn" {
  description = "ECS task role ARN (used by ECS module.)"
  value = module.iam_role.iam_role_ecs_task_role_arn
}
  
output "iam_role_ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN (used by ECS module.)"
  value = module.iam_role.iam_role_ecs_task_execution_role_arn
}

output "iam_role_lambda_master_rotation_arn" {
  description = "Master user Lambda function role ARN (used by Lambda module.)"
  value = module.iam_role.iam_role_lambda_master_rotation_arn
}

output "iam_role_lambda_app_rotation_arn" {
  description = "App user Lambda function role ARN (used by Lambda module.)"
  value = module.iam_role.iam_role_lambda_app_rotation_arn
}

output "iam_role_github_actions_role_arn" {
  description = "GitHub Actions role ARN (used for copying to AWS_ROLE_TO_ASSUME in GitHub Secrets and Variables)"
  value = module.iam_role.iam_role_github_actions_role_arn
}

## IAM AccessAnalyzer
output "iam_accessanalyzer_arn" {
  description = "Analyzer ARN"
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
  description = "AuroraクラスターのID"
  value = module.rds.rds_cluster_id
}

output "rds_cluster_writer_endpoint" {
  description = "Auroraクラスターの書き込み用エンドポイント（ECSモジュールの環境変数の設定等で使用）"
  value = module.rds.rds_cluster_writer_endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "Auroraクラスターの読み込み用エンドポイント（ECSモジュールの環境変数の設定等で使用）"
  value = module.rds.rds_cluster_reader_endpoint
}

output "rds_cluster_port" {
  description = "Aurora クラスターのポート番号（ECSモジュールの環境変数の設定等で使用）"
  value = module.rds.rds_cluster_port
}

output "rds_cluster_database_name" {
  description = "Aurora クラスターのデフォルトデータベース名（ECSモジュールの環境変数の設定等で使用）"
  value = module.rds.rds_cluster_database_name
}

output "rds_cluster_instance_details" {
  description = "Aurora クラスターのインスタンス詳細（ECSモジュールの環境変数の設定等で使用）"
  value = module.rds.rds_cluster_instance_details
}

## Lambda
output "lambda_master_function_arn" {
  description = "マスターユーザー用Lambda関数のARN"
  value = module.lambda.lambda_master_function_arn
}

output "lambda_app_function_arn" {
  description = "アプリユーザー用Lambda関数のARN"
  value = module.lambda.lambda_app_function_arn
}

## S3
output "s3_app_contents_bucket_name" {
  description = "アプリケーションのコンテンツバケットの名前"
  value = module.s3.s3_app_contents_bucket_name
}

output "s3_alb_logs_bucket_name" {
  description = "ALBのログバケットの名前（ALBモジュールでアクセスログやコネクションログを保存するために使用）"
  value = module.s3.s3_alb_logs_bucket_name
}

output "s3_cloudtrail_logs_bucket_name" {
  description = "CloudTrailのログバケットの名前（CloudTrailモジュールでログを保存するために使用）"
  value = module.s3.s3_cloudtrail_logs_bucket_name
}

## ALB
output "alb_dns_name" {
  description = "ALBのDNS名（Route53 RecordsモジュールでAliasレコードを作成する際に使用）"
  value = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "ALBのゾーンID（Route53 RecordsモジュールでAliasレコードを作成する際に使用）"
  value = module.alb.alb_zone_id
}

output "alb_front_target_group_arn" {
  description = "フロントエンドターゲットグループのARN（ECSモジュールで使用）"
  value = module.alb.alb_front_target_group_arn
}

## CloudTrail
output "cloudtrail_management_trail_arn" {
  description = "CloudTrailの管理証跡のARN"
  value = module.cloudtrail.cloudtrail_management_trail_arn
}
output "cloudtrail_data_trail_arn" {
  description = "CloudTrailのデータ証跡のARN"
  value = module.cloudtrail.cloudtrail_data_trail_arn
}

output "cloudtrail_insight_trail_arn" {
  description = "CloudTrailのインサイト証跡のARN"
  value = module.cloudtrail.cloudtrail_insight_trail_arn
}

## VPC Flow Logs
output "vpc_flow_log_arn" {
  description = "VPC Flow LogのARN"
  value = module.vpc_flow_logs.vpc_flow_log_arn
}

## Route53 Records
output "route53_records_alias_record_fqdn" {
  description = "AliasレコードのFQDN（ブラウザでALBのDNS名の別名アクセスする際に使用）"
  value = module.route53_records.route53_records_alias_record_fqdn
}

## ECR
output "ecr_repository_urls" {
  description = "マップ形式のECRリポジトリのURL（ECSモジュールのタスク定義のイメージURLとして使用）"
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
