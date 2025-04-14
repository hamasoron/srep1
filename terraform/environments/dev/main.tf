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
}

## ALBのモジュール呼び出し
module "alb" {
  source = "../../modules/alb"

  system_name      = var.system_name
  environment_name = var.environment_name
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

# RDS Aurora MySQLの作成
module "rds" {
  source = "../../modules/rds"

  system_name      = var.system_name
  environment_name = var.environment_name
  
  # データベース設定
  database_name    = "hamasorondb"
  master_username  = "hamasoron"
  master_password  = var.db_password  # tfvarsかSecrets Managerで管理
  
  # インスタンス設定
  instance_class   = "db.t4g.medium"
  
  # ネットワーク設定
  security_group_id = module.sg.security_group_ids["rds"]
  subnet_ids        = [
    module.vpc.subnet_ids["private-1a"],
    module.vpc.subnet_ids["private-1c"]
  ]
  
  # バックアップ設定（開発環境では最小限に）
  backup_retention_period = 1
  
  # セキュリティ設定（開発環境ではシンプルに）
  deletion_protection = false
  storage_encrypted   = true
  
  # 削除設定（開発環境ではスナップショット不要）
  skip_final_snapshot = true
}
