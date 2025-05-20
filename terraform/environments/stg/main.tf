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
  vpc_id           = module.vpc.vpc_id
  sg_definitions   = var.sg_definitions
  system_name      = var.system_name
  environment_name = var.environment_name
}

## IAMロールのモジュール呼び出し
module "iamrole" {
  source           = "../../modules/iamrole"
  system_name      = var.system_name
  environment_name = var.environment_name
  github_repo      = var.github_repo
}

## ALBのモジュール呼び出し
module "alb" {
  source = "../../modules/alb"

  system_name      = var.system_name
  environment_name = var.environment_name
  create_protected_ngw_associations = var.create_protected_ngw_associations
  vpc_id           = module.vpc.vpc_id
  security_group_id = module.sg.security_group_ids["alb"]
  public_subnet_ids = [
    module.vpc.public_subnet_ids["1a"],
    module.vpc.public_subnet_ids["1c"]
  ]

  enable_deletion_protection = false
  enable_https              = false
}

## ECRリポジトリのモジュール呼び出し
module "ecr" {
  source = "../../modules/ecr"

  system_name      = var.system_name
  environment_name = var.environment_name
}

## ECSクラスター・サービスのモジュール呼び出し
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
  front_security_group_id = module.sg.security_group_ids["ecs-front-nginx"]
  api_security_group_id = module.sg.security_group_ids["ecs-api-python"]

  # ロードバランサー設定
  api_target_group_arn   = module.alb.api_target_group_arn
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
}

## RDSのマスター認証情報を管理するSecretsManager
module "rds_credentials" {
  source           = "../../modules/secretsmanager"
  
  secret_name      = "${var.system_name}-${var.environment_name}-rds-master-credentials"
  description      = "RDS Aurora master credentials for ${var.system_name}-${var.environment_name}"
  secret_string    = jsonencode({
    username = "srep1admin"  # 固定ユーザー名
    password = var.db_password
  })
  
  tags = {
    Environment = var.environment_name
    System      = var.system_name
  }
}

## RDS Aurora MySQLの作成
module "rds" {
  source = "../../modules/rds"

  system_name      = var.system_name
  environment_name = var.environment_name
  region_name      = var.region_name
  
  # SecretsManagerを使用するように設定
  use_secrets_manager = true
  db_credentials_json = module.rds_credentials.secret_string
  
  # データベース設定
  database_name    = "srep1db"
  # 直接指定する代わりにSecretsManagerから取得
  # master_username  = "srep1admin"
  # master_password  = var.db_password
  
  # インスタンス設定
  instance_class   = "db.t4g.medium"
  
  # ネットワーク設定
  security_group_id = module.sg.security_group_ids["rds"]
  subnet_ids        = [
    module.vpc.subnet_ids["private-1a"],
    module.vpc.subnet_ids["private-1c"]
  ]
  
  # バックアップ設定（ステージング環境ではある程度堅牢に）
  backup_retention_period = 3
  
  # セキュリティ設定（ステージング環境では適度に）
  deletion_protection = false
  storage_encrypted   = true
  
  # 削除設定（ステージング環境ではスナップショット必要）
  skip_final_snapshot = false
}