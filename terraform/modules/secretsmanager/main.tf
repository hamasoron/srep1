# リソースの定義
## Randomプロバイダーを使用したランダムパスワード（20文字）の生成
resource "random_password" "terra_secretsmanager_secret_password" {
  for_each         = { for secret in var.secrets_list : secret.name => secret }
  length           = 20 ##### パスワードの長さを20文字に設定
  numeric          = true ##### 数字を含める
  special          = true ##### 特殊文字を含める
  override_special = "!#$%&*()-_=+[]{}<>:;.," ##### 使用する特殊文字を指定（Auroraが非対応の /, ', ", @ を除外）
  upper            = true ##### 大文字を含める
  lower            = true ##### 小文字を含める
  min_lower        = 1 ##### 小文字を最低1文字含める
  min_upper        = 1 ##### 大文字を最低1文字含める
  min_numeric      = 1 ##### 数字を最低1文字含める
  min_special      = 1 ##### 特殊文字を最低1文字含める
  keepers = {
    username = each.value.username ##### usernameが変更された時のみリソースを再生成
  }
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