# リソースの定義
## ランダムパスワード（20文字）の生成
resource "random_password" "terra_secretsmanager_secret_password" {
  for_each = { for secret in var.secrets_list : secret.name => secret }
  length   = 20
  special  = true
  override_special = "!#$%&*()-_=+[]{}<>:;.,"  ##### 使用可能な特殊文字を記述（RDS側で使用できない特殊文字は除外）
}

## RDS（Aurora）シークレットの作成
resource "aws_secretsmanager_secret" "terra_secretsmanager_secret" {
  for_each                = { for secret in var.secrets_list : secret.name => secret }
  name                    = "${var.system_name}-${var.environment_name}-aurora-${each.key}-secret"
  description             = "${var.system_name}-${var.environment_name}-aurora-${each.key} user secret"
  recovery_window_in_days = var.recovery_window_in_days
  kms_key_id              = var.secretsmanager_kms_key_id
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-${each.key}-secret"
  }
}

## RDS（Aurora）シークレットの値を設定
resource "aws_secretsmanager_secret_version" "terra_secretsmanager_secret_version" {
  for_each      = { for secret in var.secrets_list : secret.name => secret }
  secret_id     = aws_secretsmanager_secret.terra_secretsmanager_secret[each.key].id
  secret_string = jsonencode({
    username = each.value.username
    password = random_password.terra_secretsmanager_secret_password[each.key].result
  })
}