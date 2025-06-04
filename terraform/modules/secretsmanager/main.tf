# リソースの定義
## AWS Secrets Manager APIを使用したランダムパスワード（20文字）の生成
data "aws_secretsmanager_random_password" "terra_secretsmanager_secret_password" {
  for_each         = { for secret in var.secrets_list : secret.name => secret }
  password_length  = 20 ##### パスワードの長さを20文字に設定
  exclude_numbers  = false ##### 数字を除外しない
  exclude_characters = "/'\"@"  ##### Auroraが非対応の特殊文字を除外: /, ', ", @
  include_space    = false ##### スペースを含めない
  require_each_included_type = true ##### パスワードに各種文字（英字、数字、記号）を含める
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
    password = data.aws_secretsmanager_random_password.terra_secretsmanager_secret_password[each.key].random_password
  })
}