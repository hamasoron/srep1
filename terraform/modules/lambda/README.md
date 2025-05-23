# Lambda Secret Rotation Module - 詳細デプロイメントガイド
## 前提条件
### ローカルPC環境
- **Python 3.13** （Lambda runtimeと一致）
- **pip** （パッケージ管理）
- **Terraform** （v1.0以上）
- **AWS CLI** （認証設定済み）


## Terraformの実行フロー詳細
### 1. Terraform実行時の自動処理
```bash
# terraform apply実行時の内部フロー
terraform apply
```

**内部で以下が順次実行されます：**
#### Step 1: null_resourceによる依存関係インストール
```hcl
# main.tf内のnull_resource
resource "null_resource" "lambda_dependencies" {
  triggers = {
    requirements = filemd5("${path.module}/src/requirements.txt")
    code_changes = filemd5("${path.module}/src/rotation_function.py")
  }
  
  provisioner "local-exec" {
    command = <<EOF
      cd ${path.module}/src
      pip install -r requirements.txt -t .
    EOF
  }
}
```

**実際に実行されるコマンド：**
```bash
cd terraform/modules/lambda/src
pip install -r requirements.txt -t . # https://pypi.orgからパッケージがインストールされる
```

#### Step 2: archive_fileによるZIP化
```hcl
# main.tf内のarchive_file
data "archive_file" "lambda_zip" {
  depends_on  = [null_resource.lambda_dependencies]
  type        = "zip"
  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/output/lambda.zip"
  
  excludes = [
    "requirements.txt",
    "__pycache__",
    "*.pyc"
  ]
}
```

#### Step 3: Lambda関数のデプロイ
```hcl
# lambda関数の作成/更新
resource "aws_lambda_function" "terra_lambda_function_rotation" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  # ...
}
```