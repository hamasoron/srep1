# Lambda Secret Rotation Module


## ローテーション完了後にAWSCURRENTにAWSPENDINGが残る場合がある件
https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_RotateSecret.html


AWS Secrets Managerと連携してRDSデータベースのユーザーパスワードを自動的にローテーションするTerraformモジュールです。

## 概要

このモジュールは以下の機能を提供します：
- マスターユーザー（root）とアプリケーションユーザーのパスワード自動ローテーション
- Python 3.13ランタイムを使用したLambda関数の自動デプロイ
- EventBridge（CloudWatch Events）による定期実行スケジュール設定
- VPCサブネット内でのセキュアな実行環境

## アーキテクチャ

```
[EventBridge] ---(cron)---> [Lambda Function] ---(VPC)---> [RDS Cluster]
                                   ↓
                           [Secrets Manager]
```

## 提供されるリソース

### Lambda関数
- **マスターユーザー用**: `${system_name}-${environment_name}-master-secret-rotation`
- **アプリユーザー用**: `${system_name}-${environment_name}-app-secret-rotation`

### Secrets Managerローテーション設定
- マスターユーザーのシークレット自動ローテーション
- アプリケーションユーザーのシークレット自動ローテーション

### Lambda権限
- Secrets ManagerからのLambda関数呼び出し権限

## 使用方法

### 基本的な呼び出し

```hcl
module "lambda" {
  source = "../../modules/lambda"
  
  # 必須パラメータ
  system_name      = "myapp"
  environment_name = "prod"
  
  # ネットワーク設定
  lambda_protected_or_public_subnet_ids = ["subnet-12345", "subnet-67890"]
  lambda_security_group_id              = "sg-abcdef"
  
  # IAMロール
  lambda_master_role_arn = "arn:aws:iam::123456789012:role/lambda-master-role"
  lambda_app_role_arn    = "arn:aws:iam::123456789012:role/lambda-app-role"
  
  # データベース接続設定
  db_rotation_writer_host = "mydb-cluster.cluster-xyz.rds.amazonaws.com"
  db_rotation_port        = 3306
  db_cluster_identifier   = "mydb-cluster"
  
  # Secrets Manager設定
  rotation_secrets      = ["master", "app"]
  master_secret_arn     = "arn:aws:secretsmanager:region:account:secret:master-xyz"
  rotation_secret_arns  = {
    master = "arn:aws:secretsmanager:region:account:secret:master-xyz"
    app    = "arn:aws:secretsmanager:region:account:secret:app-abc"
  }
  
  # Lambda設定
  memory_size                    = 128
  timeout                        = 60
  reserved_concurrent_executions = null
  schedule_expression            = "cron(0 2 1 * ? *)"  # 毎月1日 2:00 AM
  lambda_kms_key_arn            = null
}
```

## 入力変数

### 必須変数

| 変数名 | 型 | 説明 |
|--------|-----|------|
| `system_name` | `string` | システム名 |
| `environment_name` | `string` | 環境名（dev/stg/prod等） |
| `lambda_protected_or_public_subnet_ids` | `list(string)` | Lambda関数を配置するサブネットIDのリスト |
| `lambda_security_group_id` | `string` | Lambda関数用のセキュリティグループID |
| `lambda_master_role_arn` | `string` | マスターユーザー用Lambda関数のIAMロールARN |
| `lambda_app_role_arn` | `string` | アプリユーザー用Lambda関数のIAMロールARN |
| `db_rotation_writer_host` | `string` | RDSクラスターのライターエンドポイント |
| `db_rotation_port` | `number` | RDSクラスターのポート番号 |
| `db_cluster_identifier` | `string` | RDSクラスター識別子 |
| `rotation_secrets` | `list(string)` | ローテーション対象のシークレット名リスト |
| `master_secret_arn` | `string` | マスターユーザーのシークレットARN |
| `memory_size` | `number` | Lambda関数のメモリサイズ（MB） |
| `timeout` | `number` | Lambda関数のタイムアウト秒数 |
| `schedule_expression` | `string` | ローテーションスケジュール（cron式） |

### オプション変数

| 変数名 | 型 | デフォルト値 | 説明 |
|--------|-----|-------------|------|
| `rotation_secret_arns` | `map(string)` | `{}` | ローテーション対象シークレットのARNマップ |
| `reserved_concurrent_executions` | `number` | `null` | Lambda関数の同時実行数制限 |
| `lambda_kms_key_arn` | `string` | `null` | Lambda関数で使用するKMSキーARN |

## 出力値

| 出力名 | 説明 |
|--------|------|
| `lambda_master_function_arn` | マスターユーザー用Lambda関数のARN |
| `lambda_app_function_arn` | アプリユーザー用Lambda関数のARN |

## 前提条件

### ローカル環境
- **Python 3.13**: Lambda runtimeと一致させるため
- **pip**: パッケージ管理ツール
- **Terraform**: v1.0以上
- **AWS CLI**: 認証設定済み

### AWS環境
- VPCとサブネットが既に作成済み
- セキュリティグループが適切に設定済み
- IAMロールが適切な権限で作成済み
- Secrets Managerにシークレットが作成済み
- RDSクラスターが作成済み

## デプロイフロー

### 1. 依存関係のインストール
```bash
cd terraform/modules/lambda/src
pip install -r requirements.txt -t lib/
```

### 2. Lambda関数のパッケージ化
- マスターユーザー用: `output/master_lambda.zip`
- アプリユーザー用: `output/app_lambda.zip`

### 3. AWS Lambda関数の作成/更新
- 両方の関数がVPCサブネット内にデプロイ
- 環境変数が自動設定
- Secrets Managerからの呼び出し権限が付与

### 4. ローテーション設定の有効化
- cron式に基づく自動ローテーションが開始

## セキュリティ考慮事項

- Lambda関数はVPCサブネット内で実行されます
- KMS暗号化をサポートしています（オプション）
- IAMロールベースのアクセス制御を使用します
- Secrets Managerとの通信は暗号化されます

## トラブルシューティング

### よくある問題

1. **Python依存関係エラー**
   ```
   解決策: ローカル環境でPython 3.13を使用してください
   ```

2. **VPC接続エラー**
   ```
   解決策: セキュリティグループでRDSポートへのアクセスを許可してください
   ```

3. **権限エラー**
   ```
   解決策: IAMロールにSecretsManagerとRDSへの適切な権限を付与してください
   ```

## 関連モジュール

このモジュールは以下のモジュールと連携して使用されます：
- `secretsmanager`: シークレットの作成と管理
- `rds`: データベースクラスターの作成
- `iam_role`: Lambda実行用IAMロールの作成
- `vpc`: ネットワーク設定
- `sg`: セキュリティグループ設定

## バージョン情報

- Terraform: >= 1.0
- AWS Provider: >= 4.0
- Python Runtime: 3.13