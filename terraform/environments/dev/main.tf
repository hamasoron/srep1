# メインの定義
## Route53 Zoneのモジュール呼び出し
module "route53_zone" {
  source                = "../../modules/route53_zone"
  system_name           = var.system_name
  environment_name      = var.environment_name
  route53_force_destroy = var.route53_force_destroy
  caa_records           = var.caa_records
}

## ACMのモジュール呼び出し
module "acm" {
  source                    = "../../modules/acm"
  system_name               = var.system_name
  environment_name          = var.environment_name
  domain_name               = module.route53_zone.route53_zone_name
  subject_alternative_names = var.subject_alternative_names
  route53_zone_id           = module.route53_zone.route53_zone_id
}

## VPCのモジュール呼び出し
module "vpc" {
  source                            = "../../modules/vpc"
  system_name                       = var.system_name
  environment_name                  = var.environment_name
  create_protected_ngw_associations = var.create_protected_ngw_associations
  nat_gateway_list                  = var.nat_gateway_list
  vpc_cidr                          = var.vpc_cidr
  map_public_ip_on_launch           = var.map_public_ip_on_launch
  subnet_list                       = var.subnet_list
  route_table_list                  = var.route_table_list
}

## SGのモジュール呼び出し
module "sg" {
  source           = "../../modules/sg"
  system_name      = var.system_name
  environment_name = var.environment_name
  vpc_id           = module.vpc.vpc_id
  sg_definitions   = var.sg_definitions
}

## IAM Roleのモジュール呼び出し
module "iam_role" {
  source           = "../../modules/iam_role"
  system_name      = var.system_name
  environment_name = var.environment_name
  github_repo      = var.github_repo
}

## IAM AccessAnalyzerのモジュール呼び出し
module "iam_accessanalyzer" {
  source           = "../../modules/iam_accessanalyzer"
  system_name      = var.system_name
  environment_name = var.environment_name
  analyzer_type    = var.analyzer_type
}

## CloudWatch Logsのモジュール呼び出し
module "cloudwatch_logs" {
  source                     = "../../modules/cloudwatch_logs"
  system_name                = var.system_name
  environment_name           = var.environment_name
  rds_log_configs            = var.rds_log_configs
  ecs_log_configs            = var.ecs_log_configs
  lambda_log_configs         = var.lambda_log_configs
  cloudwatch_logs_kms_key_id = var.cloudwatch_logs_kms_key_id
}

## Secrets Managerのモジュール呼び出し
module "secretsmanager" {
  source                    = "../../modules/secretsmanager"
  system_name               = var.system_name
  environment_name          = var.environment_name
  secrets_list              = var.secrets_list
  recovery_window_in_days   = var.recovery_window_in_days
  secretsmanager_kms_key_id = var.secretsmanager_kms_key_id
}

## RDSのモジュール呼び出し
module "rds" {
  source                                 = "../../modules/rds"
  system_name                            = var.system_name
  environment_name                       = var.environment_name
  private_subnet_ids                     = values(module.vpc.vpc_private_subnet_ids)
  rds_security_group_id                  = module.sg.sg_security_group_ids["rds"]
  available_azs_names                    = module.vpc.vpc_available_azs_names
  deployment_mode                        = var.deployment_mode
  ### クラスター関連
  db_engine                              = var.db_engine
  engine_version                         = var.engine_version
  database_name                          = var.database_name
  master_username                        = jsondecode(module.secretsmanager.secretsmanager_master_credentials_json)["username"]
  master_password                        = jsondecode(module.secretsmanager.secretsmanager_master_credentials_json)["password"]
  backup_retention_period                = var.backup_retention_period
  preferred_backup_window                = var.preferred_backup_window
  skip_final_snapshot                    = var.skip_final_snapshot
  deletion_protection                    = var.deletion_protection
  storage_encrypted                      = var.storage_encrypted
  rds_kms_key_id                         = var.rds_kms_key_id
  apply_immediately                      = var.apply_immediately
  preferred_maintenance_window_cluster   = var.preferred_maintenance_window_cluster
  enabled_cloudwatch_logs_exports        = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled           = var.performance_insights_enabled
  performance_insights_retention_period  = var.performance_insights_retention_period
  performance_insights_kms_key_id        = var.performance_insights_kms_key_id
  monitoring_interval                    = var.monitoring_interval
  monitoring_role_arn                    = var.monitoring_role_arn
  copy_tags_to_snapshot                  = var.copy_tags_to_snapshot
  ### インスタンス関連
  instance_class                         = var.instance_class
  auto_minor_version_upgrade             = var.auto_minor_version_upgrade
  preferred_maintenance_window_base      = var.preferred_maintenance_window_base
  publicly_accessible                    = var.publicly_accessible
  ### その他（明示的な依存関係）
  depends_on                             = [module.cloudwatch_logs, module.secretsmanager]
}

## Lambdaのモジュール呼び出し
module "lambda" {
  source                                = "../../modules/lambda"
  system_name                           = var.system_name
  environment_name                      = var.environment_name
  ### VPC関連
  lambda_protected_or_public_subnet_ids = (
    module.vpc.vpc_create_protected_ngw_associations
  ? values(module.vpc.vpc_protected_subnet_ids)
  : values(module.vpc.vpc_public_subnet_ids)
  )
  ### セキュリティグループ関連
  lambda_security_group_id              = module.sg.sg_security_group_ids["lambda"]
  ### IAM Role関連
  lambda_master_role_arn                = module.iam_role.iam_role_lambda_master_rotation_arn
  lambda_app_role_arn                   = module.iam_role.iam_role_lambda_app_rotation_arn
  ### 環境変数関連（Lambda関数の環境変数）
  db_rotation_writer_host               = module.rds.rds_cluster_writer_endpoint ##### マスターのエンドポイント
  db_rotation_port                      = module.rds.rds_cluster_port
  db_cluster_identifier                 = module.rds.rds_cluster_identifier
  master_secret_arn                     = module.secretsmanager.secretsmanager_secret_arns["master"]
  app_secret_arn                        = module.secretsmanager.secretsmanager_secret_arns["app"]
  ### Lambda関数関連
  memory_size                           = var.memory_size
  timeout                               = var.timeout
  reserved_concurrent_executions        = var.reserved_concurrent_executions
  enable_rotation_on_apply              = var.enable_rotation_on_apply
  rotation_secrets                      = var.rotation_secrets
  master_rotation_schedule_expression   = var.master_rotation_schedule_expression
  app_rotation_schedule_expression      = var.app_rotation_schedule_expression
  lambda_kms_key_arn                    = var.lambda_kms_key_arn
  ### その他（明示的な依存関係）
  depends_on                            = [module.secretsmanager, module.rds, module.iam_role, module.sg]
}

## S3のモジュール呼び出し
module "s3" {
  source              = "../../modules/s3"
  system_name         = var.system_name
  environment_name    = var.environment_name
  force_destroy       = var.force_destroy
  log_expiration_days = var.log_expiration_days
}

## ALBのモジュール呼び出し
module "alb" {
  source                               = "../../modules/alb"
  system_name                          = var.system_name
  environment_name                     = var.environment_name
  vpc_id                               = module.vpc.vpc_id
  public_subnet_ids                    = values(module.vpc.vpc_public_subnet_ids)
  security_group_id                    = module.sg.sg_security_group_ids["alb"]
  ### ALB関連
  enable_deletion_protection           = var.enable_deletion_protection
  desync_mitigation_mode               = var.desync_mitigation_mode
  enable_access_logs                   = var.enable_access_logs
  enable_connection_logs               = var.enable_connection_logs
  s3_alb_logs_bucket_name              = module.s3.s3_alb_logs_bucket_name
  ### ターゲットグループ関連
  deregistration_delay                 = var.deregistration_delay
  load_balancing_algorithm_type        = var.load_balancing_algorithm_type
  ### ヘルスチェック関連
  health_check_interval                = var.health_check_interval
  health_check_path                    = var.health_check_path
  health_check_port                    = var.health_check_port
  health_check_protocol                = var.health_check_protocol
  health_check_timeout                 = var.health_check_timeout
  health_check_healthy_threshold       = var.health_check_healthy_threshold
  health_check_unhealthy_threshold     = var.health_check_unhealthy_threshold
  health_check_matcher                 = var.health_check_matcher
  ### リスナー関連
  routing_http_response_server_enabled = var.routing_http_response_server_enabled
  certificate_arn                      = module.acm.acm_certificate_arn
  ### その他（明示的な依存関係）
  depends_on                           = [module.s3]
}

## WAFのモジュール呼び出し
module "waf" {
  source                            = "../../modules/waf"
  system_name                       = var.system_name
  environment_name                  = var.environment_name
  s3_waf_logs_bucket_arn            = module.s3.s3_waf_logs_bucket_arn
  alb_arn                           = module.alb.alb_arn
  ### WAF関連
  scope                             = var.scope
  waf_managed_rules                 = var.waf_managed_rules
  waf_rate_limit_rules              = var.waf_rate_limit_rules
  ### ログ関連
  enable_logging                    = var.enable_logging
  redacted_headers                  = var.redacted_headers
  ### その他（明示的な依存関係）
  depends_on                        = [module.s3, module.iam_role, module.alb]
}

## CloudTrailのモジュール呼び出し
module "cloudtrail" {
  source = "../../modules/cloudtrail"
  system_name                              = var.system_name
  environment_name                         = var.environment_name
  s3_cloudtrail_logs_bucket_name           = module.s3.s3_cloudtrail_logs_bucket_name
  cloudtrail_kms_key_id                    = var.cloudtrail_kms_key_id
  enable_management_logging                = var.enable_management_logging
  include_global_service_events            = var.include_global_service_events
  is_multi_region_trail                    = var.is_multi_region_trail
  enable_log_file_validation               = var.enable_log_file_validation
  event_selector_include_management_events = var.event_selector_include_management_events
  event_selector_read_write_type           = var.event_selector_read_write_type
  exclude_management_event_sources         = var.exclude_management_event_sources
  enable_data_logging                      = var.enable_data_logging
  enable_insight_logging                   = var.enable_insight_logging
  depends_on                               = [module.s3]
}

## VPC Flow Logsのモジュール呼び出し
module "vpc_flow_logs" {
  source                      = "../../modules/vpc_flow_logs"
  system_name                 = var.system_name
  environment_name            = var.environment_name
  vpc_id                      = module.vpc.vpc_id
  s3_vpc_flow_logs_bucket_arn = module.s3.s3_vpc_flow_logs_bucket_arn
  enable_vpc_flow_logs        = var.enable_vpc_flow_logs
  traffic_type                = var.traffic_type
  max_aggregation_interval    = var.max_aggregation_interval
  log_format                  = var.log_format
  destination_options         = var.destination_options
  depends_on                  = [module.vpc, module.s3]
}

## Route53 Recordsのモジュール呼び出し
module "route53_records" {
  source           = "../../modules/route53_records"
  system_name      = var.system_name
  environment_name = var.environment_name
  alb_dns_name     = module.alb.alb_dns_name
  alb_zone_id      = module.alb.alb_zone_id
  route53_zone_id  = module.route53_zone.route53_zone_id
}

## ECRのモジュール呼び出し
module "ecr" {
  source               = "../../modules/ecr"
  system_name          = var.system_name
  environment_name     = var.environment_name
  image_tag_mutability = var.image_tag_mutability
  ecr_force_delete     = var.ecr_force_delete
  encryption_type      = var.encryption_type
  ecr_kms_key          = var.ecr_kms_key
  ecr_repositories     = var.ecr_repositories
}

## CloudMapのモジュール呼び出し
module "cloudmap" {
  source           = "../../modules/cloudmap"
  system_name      = var.system_name
  environment_name = var.environment_name
  vpc_id           = module.vpc.vpc_id
  depends_on       = [module.vpc]
}

## ECSのモジュール呼び出し
module "ecs" {
  source                                  = "../../modules/ecs"
  region_name                             = var.region_name
  system_name                             = var.system_name
  environment_name                        = var.environment_name
  create_protected_ngw_associations       = var.create_protected_ngw_associations
  vpc_id                                  = module.vpc.vpc_id
  ecs_protected_or_public_subnet_ids      = (
    module.vpc.vpc_create_protected_ngw_associations
  ? values(module.vpc.vpc_protected_subnet_ids)
  : values(module.vpc.vpc_public_subnet_ids)
  )
  front_security_group_id                 = module.sg.sg_security_group_ids["ecs-front-nginx"]
  api_security_group_id                   = module.sg.sg_security_group_ids["ecs-api-python"]
  ecs_task_role_arn                       = module.iam_role.iam_role_ecs_task_role_arn
  ecs_task_execution_role_arn             = module.iam_role.iam_role_ecs_task_execution_role_arn
  front_target_group_arn                  = module.alb.alb_front_target_group_arn
  front_ecr_repository_url                = module.ecr.ecr_repository_urls["front-nginx"]
  api_ecr_repository_url                  = module.ecr.ecr_repository_urls["api-python"]
  db_initdata_ecr_repository_url          = module.ecr.ecr_repository_urls["db-initdata"]
  db_inituser_ecr_repository_url          = module.ecr.ecr_repository_urls["db-inituser"]
  cloudmap_service_arn                    = module.cloudmap.cloudmap_service_arn
  ### クラスター関連
  ecs_kms_key_id                          = var.ecs_kms_key_id
  ### タスク定義関連
  api_task_cpu                            = var.api_task_cpu
  api_task_memory                         = var.api_task_memory
  front_task_cpu                          = var.front_task_cpu
  front_task_memory                       = var.front_task_memory
  db_initdata_task_cpu                    = var.db_initdata_task_cpu
  db_initdata_task_memory                 = var.db_initdata_task_memory
  db_inituser_task_cpu                    = var.db_inituser_task_cpu
  db_inituser_task_memory                 = var.db_inituser_task_memory
  ### シークレット関連
  db_master_secret_arn                    = module.secretsmanager.secretsmanager_secret_arns["master"]
  db_app_secret_arn                       = module.secretsmanager.secretsmanager_secret_arns["app"]
  ### 環境変数関連
  db_writer_host                          = module.rds.rds_cluster_writer_endpoint
  db_reader_host                          = module.rds.rds_cluster_reader_endpoint
  db_port                                 = module.rds.rds_cluster_port
  db_name                                 = module.rds.rds_cluster_database_name
  ### サービス関連
  api_desired_count                       = var.api_desired_count
  front_desired_count                     = var.front_desired_count
  force_new_deployment                    = var.force_new_deployment
  platform_version                        = var.platform_version
  enable_execute_command                  = var.enable_execute_command
  deployment_circuit_breaker_enable       = var.deployment_circuit_breaker_enable
  deployment_circuit_breaker_rollback     = var.deployment_circuit_breaker_rollback
  deployment_controller_type              = var.deployment_controller_type
  ### CloudWatch Logs関連
  api_log_group_name                      = module.cloudwatch_logs.ecs_log_group_names["api-python"]
  front_log_group_name                    = module.cloudwatch_logs.ecs_log_group_names["front-nginx"]
  db_initdata_log_group_name              = module.cloudwatch_logs.ecs_log_group_names["db-initdata"]
  db_inituser_log_group_name              = module.cloudwatch_logs.ecs_log_group_names["db-inituser"]
  ### その他（明示的な依存関係）
  depends_on                              = [module.vpc, module.iam_role, module.cloudwatch_logs, module.alb, module.ecr, module.cloudmap]
}
