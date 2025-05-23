# リソースの定義
## 依存関係のインストール
resource "null_resource" "lambda_dependencies" {
  triggers = { ##### 以下のどちらかのファイルが変更されたら、依存関係のインストールが実行
    requirements = filemd5("${path.module}/src/requirements.txt")
    code_changes = filemd5("${path.module}/src/rotation_function.py")
  }
  provisioner "local-exec" { ##### ローカルPC環境で依存関係ファイルをインストール
    command     = <<EOF
      cd "${path.module}/src"
      pip install -r requirements.txt -t . --platform linux_x86_64 --only-binary=:all:
    EOF
    interpreter = ["PowerShell", "-Command"] ##### windows環境の場合は必要。mac環境の場合は不要。
  }
}

## Lambda関数の全てのソースコードと依存関係をZIPファイルにパッケージ化
data "archive_file" "lambda_zip" {
  depends_on  = [null_resource.lambda_dependencies]
  type        = "zip"
  source_dir  = "${path.module}/src/" ##### ソースコードのパス（なお、${path.module}は組み込み関数で、この.tfファイルのパスを表す）
  output_path = "${path.module}/output/lambda.zip" ##### 出力ファイルのパス（なお、${path.module}は組み込み関数で、この.tfファイルのパスを表す）
  excludes = [
    "requirements.txt",
    "__pycache__",
    "*.pyc"
  ]
}

## Lambda関数の作成
resource "aws_lambda_function" "terra_lambda_function_rotation" {
  function_name    = "${var.system_name}-${var.environment_name}-secret-rotation"
  description      = "For SecretsManager rotation"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = var.lambda_role_arn
  handler          = "rotation_function.lambda_handler"
  runtime          = "python3.13"
  memory_size      = var.memory_size
  timeout          = var.timeout
  reserved_concurrent_executions = var.reserved_concurrent_executions
  
  # VPC設定を追加
  vpc_config {
    subnet_ids         = var.lambda_protected_or_public_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }
  
  environment {
    variables = {
      DB_LOTATION_WRITER_HOST = var.db_lotation_writer_host
      DB_LOTATION_PORT = var.db_lotation_port
    }
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-secret-rotation"
  }
}

## Lambda関数のリソースベースのポリシーを追加（SecretsManagerがLambdaを呼び出す際に必要）
resource "aws_lambda_permission" "secretsmanager" {
  statement_id  = "AllowSecretsManagerToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terra_lambda_function_rotation.function_name
  principal     = "secretsmanager.amazonaws.com"
}

## SecretsManagerローテーション設定（毎月1日の深夜3時に1回）
resource "aws_secretsmanager_secret_rotation" "terra_secretsmanager_secret_rotation" {
  for_each = var.rotation_secret_arns
  secret_id           = each.value
  rotation_lambda_arn = aws_lambda_function.terra_lambda_function_rotation.arn
  rotation_rules {
    schedule_expression = var.schedule_expression ##### cron式（分 時 日 月 曜日 年）で設定
  }
} 