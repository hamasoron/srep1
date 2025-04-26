# メインの定義
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

## RDS（Aurora MySQL）のモジュール呼び出し
module "rds" {
  source           = "../../modules/rds"
  system_name      = var.system_name
  environment_name = var.environment_name
  subnet_ids        = [module.vpc.subnet_ids["private-1a"], module.vpc.subnet_ids["private-1c"]]
  security_group_id = module.sg.security_group_ids["rds"]
  ### クラスター関連
  region_name = var.region_name
  db_engine        = var.db_engine
  engine_version   = var.engine_version
  database_name    = var.database_name
  master_username  = var.master_username
  master_password  = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection
  storage_encrypted = var.storage_encrypted
  kms_key_id = var.kms_key_id
  apply_immediately = var.apply_immediately
  preferred_maintenance_window_cluster = var.preferred_maintenance_window_cluster
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  ### インスタンス関連
  promotion_tier = var.promotion_tier
  instance_class   = var.instance_class
  preferred_maintenance_window_instanceA = var.preferred_maintenance_window_instanceA
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  enable_performance_insights = var.enable_performance_insights
  monitoring_interval = var.monitoring_interval
}

## S3バケットのモジュール呼び出し
module "s3" {
  source           = "../../modules/s3"
  system_name      = var.system_name
  environment_name = var.environment_name
  force_destroy = var.force_destroy
  log_expiration_days = var.log_expiration_days
}

## ALBのモジュール呼び出し
module "alb" {
  source = "../../modules/alb"
  system_name      = var.system_name
  environment_name = var.environment_name
  create_protected_ngw_associations = var.create_protected_ngw_associations
  vpc_id           = module.vpc.vpc_id
  public_subnet_ids = [module.vpc.public_subnet_ids["1a"], module.vpc.public_subnet_ids["1c"]]
  protected_subnet_ids = var.create_protected_ngw_associations ? [module.vpc.subnet_ids["protected-1a"],module.vpc.subnet_ids["protected-1c"]] : []
  security_group_id = module.sg.security_group_ids["alb"]
  enable_deletion_protection = var.enable_deletion_protection
  deregistration_delay = var.deregistration_delay
  enable_access_logs = var.enable_access_logs
  enable_connection_logs = var.enable_connection_logs
}

## ECRのモジュール呼び出し
module "ecr" {
  source = "../../modules/ecr"
  system_name      = var.system_name
  environment_name = var.environment_name
  enable_ecr_lifecycle_policy = var.enable_ecr_lifecycle_policy
  ecr_lifecycle_policy_count = var.ecr_lifecycle_policy_count
}

## ECSのモジュール呼び出し
module "ecs" {
  source = "../../modules/ecs"

  system_name      = var.system_name
  environment_name = var.environment_name
  create_protected_ngw_associations = var.create_protected_ngw_associations
  region           = var.region_name

  # IAMロール
  ecs_task_execution_role_arn = module.iamrole.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.iamrole.ecs_task_role_arn

  # ネットワーク設定
  vpc_id = module.vpc.vpc_id
  protected_subnet_ids = var.create_protected_ngw_associations ? [
    module.vpc.subnet_ids["protected-1a"],
    module.vpc.subnet_ids["protected-1c"]
  ] : []
  public_subnet_ids = [
    module.vpc.public_subnet_ids["1a"],
    module.vpc.public_subnet_ids["1c"]
  ]
  ecs_security_group_id = module.sg.security_group_ids["ecs-front-nginx"]

  # ロードバランサー設定
  front_target_group_arn = module.alb.front_target_group_arn

  # ECRリポジトリ
  api_ecr_repository_url   = module.ecr.api_repository_url
  front_ecr_repository_url = module.ecr.front_repository_url

  # タスク設定
  api_task_cpu        = "256"
  api_task_memory     = "512"
  api_desired_count   = var.api_desired_count
  front_task_cpu      = "256"
  front_task_memory   = "512"
  front_desired_count = var.front_desired_count
  log_retention_days  = 7
  
  # 明示的な依存関係（以下は必須のため、必ず記載する）
  depends_on = [module.vpc, module.alb]
}