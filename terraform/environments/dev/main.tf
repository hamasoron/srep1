# メインの定義
## Route53_zoneのモジュール呼び出し
module "route53_zone" {
  source                = "../../modules/route53_zone"
  system_name           = var.system_name
  environment_name      = var.environment_name
  route53_force_destroy = var.route53_force_destroy
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
  vpc_cidr                          = var.vpc_cidr
  subnet_list                       = var.subnet_list
  route_table_list                  = var.route_table_list
}

## セキュリティグループのモジュール呼び出し
module "sg" {
  source           = "../../modules/sg"
  system_name      = var.system_name
  environment_name = var.environment_name
  vpc_id           = module.vpc.vpc_id
  sg_definitions   = var.sg_definitions
}

## IAMロールのモジュール呼び出し
module "iamrole" {
  source      = "../../modules/iamrole"
  github_repo = var.github_repo
}

## SecretsManagerモジュールの呼び出し
module "secretsmanager" {
  source                    = "../../modules/secretsmanager"
  region_name               = var.region_name
  system_name               = var.system_name
  environment_name          = var.environment_name
  recovery_window_in_days   = var.recovery_window_in_days
  secretsmanager_kms_key_id = var.secretsmanager_kms_key_id
  master_username           = var.master_username
  master_password           = var.master_password
  app_username              = var.app_username
  app_password              = var.app_password
}

## RDSモジュールの呼び出し
module "rds" {
  source                                 = "../../modules/rds"
  region_name                            = var.region_name
  system_name                            = var.system_name
  environment_name                       = var.environment_name
  subnet_ids                             = values(module.vpc.private_subnet_ids)
  security_group_id                      = module.sg.security_group_ids["rds"]
  ### クラスター関連
  db_engine                              = var.db_engine
  engine_version                         = var.engine_version
  database_name                          = var.database_name
  master_username                        = jsondecode(module.secretsmanager.master_credentials_json)["username"]
  master_password                        = jsondecode(module.secretsmanager.master_credentials_json)["password"]
  backup_retention_period                = var.backup_retention_period
  preferred_backup_window                = var.preferred_backup_window
  skip_final_snapshot                    = var.skip_final_snapshot
  deletion_protection                    = var.deletion_protection
  storage_encrypted                      = var.storage_encrypted
  rds_kms_key_id                         = var.rds_kms_key_id
  apply_immediately                      = var.apply_immediately
  preferred_maintenance_window_cluster   = var.preferred_maintenance_window_cluster
  enabled_cloudwatch_logs_exports        = var.enabled_cloudwatch_logs_exports
  copy_tags_to_snapshot                  = var.copy_tags_to_snapshot
  ### インスタンス関連
  promotion_tier                         = var.promotion_tier
  instance_class                         = var.instance_class
  preferred_maintenance_window_instanceA = var.preferred_maintenance_window_instanceA
  auto_minor_version_upgrade             = var.auto_minor_version_upgrade
  enable_performance_insights            = var.enable_performance_insights
  monitoring_interval                    = var.monitoring_interval
  ### その他（明示的な依存関係）
  depends_on                             = [module.secretsmanager]
}

## S3バケットのモジュール呼び出し
module "s3" {
  source              = "../../modules/s3"
  system_name         = var.system_name
  environment_name    = var.environment_name
  force_destroy       = var.force_destroy
  log_expiration_days = var.log_expiration_days
}

## ALBのモジュール呼び出し
module "alb" {
  source                           = "../../modules/alb"
  system_name                      = var.system_name
  environment_name                 = var.environment_name
  vpc_id                           = module.vpc.vpc_id
  public_subnet_ids                = values(module.vpc.public_subnet_ids)
  security_group_id                = module.sg.security_group_ids["alb"]
  ### ALB関連
  enable_deletion_protection       = var.enable_deletion_protection
  enable_access_logs               = var.enable_access_logs
  enable_connection_logs           = var.enable_connection_logs
  certificate_arn                  = module.acm.certificate_arn
  ### ターゲットグループ関連
  deregistration_delay             = var.deregistration_delay
  load_balancing_algorithm_type    = var.load_balancing_algorithm_type
  ### ヘルスチェック関連
  health_check_interval            = var.health_check_interval
  health_check_path                = var.health_check_path
  health_check_port                = var.health_check_port
  health_check_protocol            = var.health_check_protocol
  health_check_timeout             = var.health_check_timeout
  health_check_healthy_threshold   = var.health_check_healthy_threshold
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold
  health_check_matcher             = var.health_check_matcher
  ### その他（明示的な依存関係）
  depends_on                       = [module.s3]
}

## Route53_recordsのモジュール呼び出し
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
  source                      = "../../modules/ecr"
  system_name                 = var.system_name
  environment_name            = var.environment_name
  image_tag_mutability        = var.image_tag_mutability
  scan_on_push                = var.scan_on_push
  ecr_force_delete            = var.ecr_force_delete
  encryption_type             = var.encryption_type
  ecr_kms_key                 = var.ecr_kms_key
  enable_ecr_lifecycle_policy = var.enable_ecr_lifecycle_policy
  ecr_lifecycle_policy_count  = var.ecr_lifecycle_policy_count
}

## CloudWatch Logsモジュールの呼び出し
module "cloudwatch_logs" {
  source             = "../../modules/cloudwatch_logs"
  system_name        = var.system_name
  environment_name   = var.environment_name
  log_retention_days = var.log_retention_days
  services           = [
    { name = "api-python" },
    { name = "front-nginx" },
    { name = "db-initdata" }
  ]
}

## ECSのモジュール呼び出し
module "ecs" {
  source                              = "../../modules/ecs"
  region_name                         = var.region_name
  system_name                         = var.system_name
  environment_name                    = var.environment_name
  create_protected_ngw_associations   = var.create_protected_ngw_associations
  vpc_id                              = module.vpc.vpc_id
  subnet_ids                          = (
    module.vpc.create_protected_ngw_associations
  ? values(module.vpc.protected_subnet_ids)
  : values(module.vpc.public_subnet_ids)
  )
  front_security_group_id             = module.sg.security_group_ids["ecs-front-nginx"]
  api_security_group_id               = module.sg.security_group_ids["ecs-api-python"]
  ecs_task_role_arn                   = module.iamrole.ecs_task_role_arn
  ecs_task_execution_role_arn         = module.iamrole.ecs_task_execution_role_arn
  front_target_group_arn              = module.alb.front_target_group_arn
  front_ecr_repository_url            = module.ecr.front_repository_url
  api_ecr_repository_url              = module.ecr.api_repository_url
  db_initdata_ecr_repository_url      = module.ecr.db_initdata_repository_url
  ### クラスター関連
  ecs_kms_key_id                      = var.ecs_kms_key_id
  ### タスク定義関連
  api_task_cpu                        = var.api_task_cpu
  api_task_memory                     = var.api_task_memory
  front_task_cpu                      = var.front_task_cpu
  front_task_memory                   = var.front_task_memory
  db_initdata_task_cpu                = var.db_initdata_task_cpu
  db_initdata_task_memory             = var.db_initdata_task_memory
  ### シークレット関連
  db_master_secret_arn                = module.secretsmanager.rds_master_secret_arn
  ### 環境変数関連
  db_host                             = module.rds.cluster_endpoint
  db_port                             = module.rds.cluster_port
  db_name                             = module.rds.cluster_database_name
  ### サービス関連
  api_desired_count                   = var.api_desired_count
  front_desired_count                 = var.front_desired_count
  force_new_deployment                = var.force_new_deployment
  platform_version                    = var.platform_version
  enable_execute_command              = var.enable_execute_command
  deployment_circuit_breaker_enable   = var.deployment_circuit_breaker_enable
  deployment_circuit_breaker_rollback = var.deployment_circuit_breaker_rollback
  deployment_controller_type          = var.deployment_controller_type
  ### CloudWatch Logs関連
  api_log_group_name                  = module.cloudwatch_logs.log_group_names["api-python"]
  front_log_group_name                = module.cloudwatch_logs.log_group_names["front-nginx"]
  db_initdata_log_group_name          = module.cloudwatch_logs.log_group_names["db-initdata"]
  ### その他（明示的な依存関係）
  depends_on                          = [module.vpc, module.iamrole, module.alb, module.ecr, module.cloudwatch_logs]
}