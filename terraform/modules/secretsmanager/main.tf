# リソースの定義
## データリソース（現在のAWSアカウントのIDを取得）
data "aws_caller_identity" "terra_caller_identity" {}

## RDS（Aurora）シークレットの作成（マスターユーザー）
resource "aws_secretsmanager_secret" "terra_secretsmanager_secret_master" {
  name        = "${var.system_name}-${var.environment_name}-aurora-master-secret"
  description = "The secret associated with the master user of the RDS DB cluster: arn:aws:rds:${var.region_name}:${data.aws_caller_identity.terra_caller_identity.account_id}:cluster:${var.system_name}-${var.environment_name}-aurora-cluster"
  recovery_window_in_days = var.recovery_window_in_days
  kms_key_id = var.secretsmanager_kms_key_id
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-master-secret"
  }
}

## RDS（Aurora）シークレットの値を設定（マスターユーザー）
resource "aws_secretsmanager_secret_version" "terra_secretsmanager_secret_version_rds_master" {
  secret_id     = aws_secretsmanager_secret.terra_secretsmanager_secret_master.id
  secret_string = jsonencode({
    username = var.master_username
    password = var.master_password
  })
}

## RDS（Aurora）シークレットの作成（アプリケーションユーザー）
resource "aws_secretsmanager_secret" "terra_secretsmanager_secret_app" {
  name        = "${var.system_name}-${var.environment_name}-aurora-app-secret"
  description = "The secret associated with the application user of the RDS DB cluster: arn:aws:rds:${var.region_name}:${data.aws_caller_identity.terra_caller_identity.account_id}:cluster:${var.system_name}-${var.environment_name}-aurora-cluster"
  recovery_window_in_days = var.recovery_window_in_days
  kms_key_id = var.secretsmanager_kms_key_id
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-app-secret"
  }
}

## RDS（Aurora）シークレットの値を設定（アプリケーションユーザー）
resource "aws_secretsmanager_secret_version" "terra_secretsmanager_secret_version_rds_app" {
  secret_id     = aws_secretsmanager_secret.terra_secretsmanager_secret_app.id
  secret_string = jsonencode({
    username = var.app_username
    password = var.app_password
  })
}