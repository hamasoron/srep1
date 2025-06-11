# リソースの定義
## 依存関係のインストール
resource "null_resource" "lambda_dependencies" {
  triggers = { ##### 以下のファイルが変更されたら、依存関係のインストールが実行
    requirements = filemd5("${path.module}/src/requirements.txt")
    master_code_changes = filemd5("${path.module}/src/master_rotation_function.py")
    app_code_changes = filemd5("${path.module}/src/app_rotation_function.py")
  }
  provisioner "local-exec" { ##### ローカルPC環境で依存関係ファイルをインストール
    command     = <<EOF
      cd "${path.module}/src/"
      pip install -r requirements.txt -t lib/
    EOF
    interpreter = ["PowerShell", "-Command"] ##### ローカルPCがWindowsの場合は必要。Macの場合は不要。
  }
}

## マスターユーザー用Lambda関数のZIPファイルにパッケージ化
data "archive_file" "master_lambda_zip" {
  depends_on  = [null_resource.lambda_dependencies]
  type        = "zip"
  source_dir  = "${path.module}/src/" ##### ZIP化したいソースのパス（なお、${path.module}は組み込み関数で、この.tfファイルのパスを表す）
  output_path = "${path.module}/output/master_lambda.zip" ##### ZIP化したファイルの出力先
  excludes = [ ##### ZIP化したくないファイルを指定
    "requirements.txt",
    "__pycache__",
    "*.pyc",
    "app_rotation_function.py"
  ]
}

## アプリユーザー用Lambda関数のZIPファイルにパッケージ化
data "archive_file" "app_lambda_zip" {
  depends_on  = [null_resource.lambda_dependencies]
  type        = "zip"
  source_dir  = "${path.module}/src/" ##### ZIP化したいソースのパス（なお、${path.module}は組み込み関数で、この.tfファイルのパスを表す）
  output_path = "${path.module}/output/app_lambda.zip" ##### ZIP化したファイルの出力先
  excludes = [ ##### ZIP化したくないファイルを指定
    "requirements.txt",
    "__pycache__",
    "*.pyc",
    "master_rotation_function.py"
  ]
}

## マスターユーザー用Lambda関数の作成
resource "aws_lambda_function" "terra_lambda_function_master_rotation" {
  function_name    = "${var.system_name}-${var.environment_name}-master-secret-rotation"
  description      = "For SecretsManager master user rotation"
  filename         = data.archive_file.master_lambda_zip.output_path
  source_code_hash = data.archive_file.master_lambda_zip.output_base64sha256
  role             = var.lambda_master_role_arn
  handler          = "master_rotation_function.lambda_handler" ##### ハンドラー（コード名.lambda_handler）
  runtime          = "python3.13"
  memory_size      = var.memory_size
  timeout          = var.timeout
  reserved_concurrent_executions = var.reserved_concurrent_executions
  kms_key_arn = var.lambda_kms_key_arn
  vpc_config {
    subnet_ids         = var.lambda_protected_or_public_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }
  environment {
    variables = {
      DB_ROTATION_WRITER_HOST = var.db_rotation_writer_host
      DB_ROTATION_PORT = var.db_rotation_port
      DB_CLUSTER_IDENTIFIER = var.db_cluster_identifier
    }
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-master-secret-rotation"
  }
  ### ENIクリーンアップが先に実行されるように依存関係を設定
  depends_on = [null_resource.lambda_eni_cleanup_wait]
}

## アプリユーザー用Lambda関数の作成
resource "aws_lambda_function" "terra_lambda_function_app_rotation" {
  function_name    = "${var.system_name}-${var.environment_name}-app-secret-rotation"
  description      = "For SecretsManager app user rotation"
  filename         = data.archive_file.app_lambda_zip.output_path
  source_code_hash = data.archive_file.app_lambda_zip.output_base64sha256
  role             = var.lambda_app_role_arn
  handler          = "app_rotation_function.lambda_handler" ##### ハンドラー（コード名.lambda_handler）
  runtime          = "python3.13"
  memory_size      = var.memory_size
  timeout          = var.timeout
  reserved_concurrent_executions = var.reserved_concurrent_executions
  kms_key_arn = var.lambda_kms_key_arn
  vpc_config {
    subnet_ids         = var.lambda_protected_or_public_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }
  environment {
    variables = {
      DB_ROTATION_WRITER_HOST = var.db_rotation_writer_host
      DB_ROTATION_PORT = var.db_rotation_port
      MASTER_SECRET_ARN = var.master_secret_arn
      APP_SECRET_ARN = var.app_secret_arn
    }
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-app-secret-rotation"
  }
  ### ENIクリーンアップが先に実行されるように依存関係を設定
  depends_on = [null_resource.lambda_eni_cleanup_wait]
}

## Lambda関数削除時のENIクリーンアップ待機（VPC LambdaはENIが削除可能（In-use → Available）になるまで最大20分かかる）
### なお、AvailableになったらLambdaサービスが実行ロールを使用してENIを自動で削除してくれる
### 参考：https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html
resource "null_resource" "lambda_eni_cleanup_wait" {
  # 作成時は何もしない、削除時のみENIクリーンアップを実行
  lifecycle {
    create_before_destroy = false
  }
  # 削除時にENIがクリーンアップ（Availableになる）されるまで待機（最大20分）
  provisioner "local-exec" {
    # terraform destroy時のみ以下のコマンドを実行
    when    = destroy
    command = <<-EOT
      Write-Host "Starting ENI cleanup process..."
      $timeout = 1200
      $elapsed = 0
      do {
        try {
          $enis = aws ec2 describe-network-interfaces --filters "Name=description,Values=AWS Lambda VPC ENI*" --query "NetworkInterfaces[].NetworkInterfaceId" --output text 2>$null
          if ([string]::IsNullOrWhiteSpace($enis) -or $enis -eq "None") {
            Write-Host "No Lambda VPC ENIs found. Cleanup completed."
            break
          }
          $eniArray = ($enis -split '\s+') | Where-Object { $_ -ne '' -and $_ -ne 'None' }
          if ($eniArray.Count -eq 0) {
            Write-Host "ENI cleanup completed - no ENIs to process"
            break
          }
          Write-Host "Found $($eniArray.Count) Lambda VPC ENI(s) still present. Waiting for automatic cleanup by AWS..."
          Write-Host "ENI cleanup in progress... ($elapsed seconds elapsed)"
          Start-Sleep 60
          $elapsed += 60
        } catch {
          Write-Host "Error during ENI cleanup: $_.Exception.Message"
          Start-Sleep 60
          $elapsed += 60
        }
      } while ($elapsed -lt $timeout)
      if ($elapsed -ge $timeout) {
        Write-Host "ENI cleanup timed out after $timeout seconds"
      } else {
        Write-Host "ENI cleanup completed successfully"
      }
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}

# SecretsManagerとカスタムLambdaのローテーションの流れ
# [Secrets Manager] --(Invoke)--> [Lambda (rotation)] --(Connects/Updates)--> [RDS(MySQL, etc.)]
#      ↑                                                         ↓
#      +-----------(Get/Put Secret via SDK/API)------------------+

## マスターユーザー用Lambda関数のリソースベースのポリシーを追加（SecretsManagerがLambda関数を呼び出すためのポリシー）
resource "aws_lambda_permission" "terra_secretsmanager_master" {
  source_arn    = var.master_secret_arn
  statement_id  = "AllowSecretsManagerToInvokeMasterLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terra_lambda_function_master_rotation.function_name
  principal     = "secretsmanager.amazonaws.com"
}

## アプリユーザー用Lambda関数のリソースベースのポリシーを追加（SecretsManagerがLambda関数を呼び出すためのポリシー）
resource "aws_lambda_permission" "terra_secretsmanager_app" {
  source_arn    = var.app_secret_arn
  statement_id  = "AllowSecretsManagerToInvokeAppLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terra_lambda_function_app_rotation.function_name
  principal     = "secretsmanager.amazonaws.com"
}

## SecretsManagerローテーション設定（マスターユーザー）
resource "aws_secretsmanager_secret_rotation" "terra_secretsmanager_master_secret_rotation" {
  count = var.enable_rotation_on_apply && contains(var.rotation_secrets, "master") ? 1 : 0 ##### ローテーション有効フラグとmasterの存在をチェック
  secret_id           = var.master_secret_arn
  rotation_lambda_arn = aws_lambda_function.terra_lambda_function_master_rotation.arn
  rotation_rules {
    schedule_expression = var.master_rotation_schedule_expression ##### cron式（分 時 日 月 曜日 年）で設定
  }
}

## SecretsManagerローテーション設定（アプリユーザー）
resource "aws_secretsmanager_secret_rotation" "terra_secretsmanager_app_secret_rotation" {
  count = var.enable_rotation_on_apply && contains(var.rotation_secrets, "app") ? 1 : 0 ##### ローテーション有効フラグとappの存在をチェック
  secret_id           = var.app_secret_arn
  rotation_lambda_arn = aws_lambda_function.terra_lambda_function_app_rotation.arn
  rotation_rules {
    schedule_expression = var.app_rotation_schedule_expression ##### cron式（分 時 日 月 曜日 年）で設定
  }
} 