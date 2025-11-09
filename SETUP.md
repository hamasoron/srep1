# セットアップガイド

このドキュメントでは、SREP1プロジェクトを自分の環境で構築する手順を詳しく説明します。

---

## 📋 目次

1. [前提条件](#1-前提条件)
2. [AWSアカウント準備](#2-awsアカウント準備)
3. [GitHub設定](#3-github設定)
4. [Terraformセットアップ](#4-terraformセットアップ)
5. [インフラ構築](#5-インフラ構築)
6. [アプリケーションデプロイ](#6-アプリケーションデプロイ)
7. [動作確認](#7-動作確認)
8. [環境削除](#8-環境削除)

---

## 1. 前提条件

### 必要なツール

| ツール | バージョン | インストール方法 |
|--------|-----------|----------------|
| **Terraform** | 1.5以上 | [公式サイト](https://www.terraform.io/downloads) |
| **AWS CLI** | 2.x | [AWS CLI インストール](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| **Docker** | 20.x以上 | [Docker Desktop](https://www.docker.com/products/docker-desktop) |
| **Git** | 2.x | [Git公式サイト](https://git-scm.com/) |

### 必要な知識

- 基本的なAWSサービスの理解（VPC, EC2, ECS, RDS）
- Terraformの基礎知識
- GitHubの基本操作
- Dockerの基本的な使い方

### 必要な権限

- AWSアカウントの管理者権限（または以下のサービスへのフルアクセス）
  - VPC, EC2, ECS, ECR, RDS, ALB, Route53, ACM
  - CloudWatch, SNS, Lambda, Secrets Manager
  - IAM, S3

---

## 2. AWSアカウント準備

### 2.1 AWS CLIの設定

```bash
# AWS CLI設定
aws configure

# 入力内容
AWS Access Key ID [None]: YOUR_ACCESS_KEY
AWS Secret Access Key [None]: YOUR_SECRET_KEY
Default region name [None]: ap-northeast-1
Default output format [None]: json
```

### 2.2 Terraform State用S3バケット作成

```bash
# バケット名を環境変数に設定
export TF_STATE_BUCKET="your-terraform-state-bucket-$(date +%s)"

# S3バケット作成
aws s3 mb s3://${TF_STATE_BUCKET} --region ap-northeast-1

# バージョニング有効化
aws s3api put-bucket-versioning \
  --bucket ${TF_STATE_BUCKET} \
  --versioning-configuration Status=Enabled

# パブリックアクセスブロック有効化
aws s3api put-public-access-block \
  --bucket ${TF_STATE_BUCKET} \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

### 2.3 GitHub Actions用IAMロール作成（OIDC）

#### 2.3.1 OIDCプロバイダー作成

```bash
# GitHubのOIDCプロバイダーを作成
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

#### 2.3.2 IAMロール作成

trust-policy.json:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/srep1:*"
        }
      }
    }
  ]
}
```

```bash
# YOUR_ACCOUNT_IDとYOUR_GITHUB_USERNAMEを置換
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export GITHUB_USERNAME="your-github-username"

# trust-policy.jsonを作成（上記のJSONを使用）
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_USERNAME}/srep1:*"
        }
      }
    }
  ]
}
EOF

# IAMロール作成
aws iam create-role \
  --role-name GitHubActionsRole \
  --assume-role-policy-document file://trust-policy.json

# 必要なポリシーをアタッチ（管理者権限 - 本番環境では最小権限にすること）
aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

---

## 3. GitHub設定

### 3.1 リポジトリフォーク/クローン

```bash
# GitHubでフォークまたはクローン
git clone https://github.com/YOUR_USERNAME/srep1.git
cd srep1
```

### 3.2 GitHub Secretsの設定

GitHub リポジトリの `Settings` > `Secrets and variables` > `Actions` で以下を設定:

| シークレット名 | 値 | 説明 |
|---------------|-----|------|
| `AWS_ROLE_TO_ASSUME` | `arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubActionsRole` | 前のステップで作成したIAMロールのARN |

**確認方法:**
```bash
# IAMロールARNを取得
aws iam get-role --role-name GitHubActionsRole --query 'Role.Arn' --output text
```

---

## 4. Terraformセットアップ

### 4.1 backend.tf の編集

```bash
cd terraform/environments/dev
```

`backend.tf` を編集:
```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket-xxxx"  # 作成したバケット名
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
```

### 4.2 terraform.tfvars の作成

```bash
# サンプルからコピー
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars` を編集:
```hcl
# 基本設定
region_name      = "ap-northeast-1"
system_name      = "srep1"
environment_name = "dev"

# VPC設定
vpc_cidr_block = "10.0.0.0/16"

# サブネット設定（2AZ構成）
subnet_list = [
  { name = "1a", cidr_block = "10.0.64.0/24", type = "public" },
  { name = "1a", cidr_block = "10.0.0.0/24", type = "private" },
  { name = "1c", cidr_block = "10.0.65.0/24", type = "public" },
  { name = "1c", cidr_block = "10.0.1.0/24", type = "private" },
]

# NAT Gateway設定（dev環境はコスト削減のため1台のみ）
nat_gateway_list = [
  { az = "1a", enabled = true },
  { az = "1c", enabled = false },
]

# Aurora設定
use_all_azs_for_aurora = false  # dev環境は1台構成

# RDSマスターユーザー設定
db_master_username = "admin"
db_name            = "srep1db"

# Route53設定（オプション - 独自ドメインを使う場合）
# route53_zone_name = "example.com"
# create_route53_zone = false  # 既存のホストゾーンを使用
```

### 4.3 stg/prod環境の設定（オプション）

同様に `terraform/environments/stg/` と `terraform/environments/prod/` も設定します。

---

## 5. インフラ構築

### 5.1 dev環境の構築

```bash
cd terraform/environments/dev

# Terraform初期化
terraform init

# プラン確認（約5分）
terraform plan -var-file="terraform.tfvars"

# 適用（約15-20分）
terraform apply -var-file="terraform.tfvars"
```

**注意**: 初回は以下のリソースが作成されます：
- VPC、サブネット、NAT Gateway
- ECSクラスター
- Aurora MySQL（起動に約10分）
- ALB、セキュリティグループ
- Lambda（Secrets Managerローテーション）
- CloudWatch Logs、SNSなど

### 5.2 出力値の確認

```bash
# 作成されたリソースの情報を確認
terraform output

# 主要な出力値
# - alb_dns_name: ALBのDNS名
# - ecr_repositories: ECRリポジトリURL
# - rds_cluster_endpoint: RDS Writerエンドポイント
# - rds_reader_endpoint: RDS Readerエンドポイント
```

---

## 6. アプリケーションデプロイ

### 6.1 初回のECRへのイメージプッシュ

Terraformでインフラが作成された後、初回のみ手動でイメージをプッシュします。

```bash
# ルートディレクトリに戻る
cd ../../../

# ECRログイン
aws ecr get-login-password --region ap-northeast-1 | \
  docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com

# フロントエンドイメージのビルド・プッシュ
cd app/front-nginx
docker build -t srep1-dev-front-nginx:latest .
docker tag srep1-dev-front-nginx:latest \
  ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/srep1-dev-front-nginx-repo:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/srep1-dev-front-nginx-repo:latest

# バックエンドイメージのビルド・プッシュ
cd ../api-python
docker build -t srep1-dev-api-python:latest .
docker tag srep1-dev-api-python:latest \
  ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/srep1-dev-api-python-repo:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/srep1-dev-api-python-repo:latest

# DB初期化イメージのビルド・プッシュ
cd ../db-initdata
docker build -t srep1-dev-db-initdata:latest .
docker tag srep1-dev-db-initdata:latest \
  ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/srep1-dev-db-initdata-repo:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/srep1-dev-db-initdata-repo:latest

cd ../db-inituser
docker build -t srep1-dev-db-inituser:latest .
docker tag srep1-dev-db-inituser:latest \
  ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/srep1-dev-db-inituser-repo:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/srep1-dev-db-inituser-repo:latest
```

### 6.2 ECSサービスの起動確認

```bash
# ECSタスクの状態確認
aws ecs list-tasks --cluster srep1-dev-ecs-cluster

# タスク詳細確認
aws ecs describe-tasks \
  --cluster srep1-dev-ecs-cluster \
  --tasks $(aws ecs list-tasks --cluster srep1-dev-ecs-cluster --query 'taskArns[0]' --output text)
```

### 6.3 GitHub Actionsによる自動デプロイ設定

以降は、コードをGitHubにプッシュするだけで自動デプロイされます。

```bash
# 変更をコミット・プッシュ
git add .
git commit -m "Initial deployment"
git push origin main
```

GitHub Actionsが自動的にトリガーされ、ビルド・デプロイが実行されます。

---

## 7. 動作確認

### 7.1 ALBエンドポイントの取得

```bash
# ALBのDNS名を取得
terraform output alb_dns_name
```

### 7.2 ブラウザでアクセス

```
http://<ALB_DNS_NAME>/
```

以下の機能を確認:
- **API接続テスト**ボタン: 正常に「API接続テストが成功しました」が表示される
- **DB接続テスト**ボタン: 正常に「DB接続テストが成功しました（件数: X）」が表示される

### 7.3 CloudWatch Logsの確認

```bash
# ログストリーム確認
aws logs tail /aws/ecs/srep1-dev-front-nginx --follow
aws logs tail /aws/ecs/srep1-dev-api-python --follow
```

---

## 8. 環境削除

### 8.1 リソースの削除

```bash
cd terraform/environments/dev

# 削除確認
terraform plan -destroy -var-file="terraform.tfvars"

# 削除実行（約15分）
terraform destroy -var-file="terraform.tfvars"
```

### 8.2 手動削除が必要なリソース

以下のリソースは手動で削除してください:

#### S3バケット（tfstate）
```bash
# バケット内オブジェクト削除
aws s3 rm s3://${TF_STATE_BUCKET} --recursive

# バケット削除
aws s3 rb s3://${TF_STATE_BUCKET}
```

#### ECRリポジトリのイメージ
```bash
# イメージ一覧取得
aws ecr list-images --repository-name srep1-dev-front-nginx-repo

# イメージ削除
aws ecr batch-delete-image \
  --repository-name srep1-dev-front-nginx-repo \
  --image-ids imageTag=latest

# 同様に他のリポジトリも削除
```

---

## 🆘 トラブルシューティング

### 問題1: terraform apply でタイムアウト

**症状**: `Error: timeout while waiting for state to become 'available'`

**原因**: RDS Auroraの起動に時間がかかっている

**解決**:
```bash
# RDSの状態確認
aws rds describe-db-clusters \
  --db-cluster-identifier srep1-dev-aurora-cluster \
  --query 'DBClusters[0].Status'

# 10-15分待ってから再実行
terraform apply -var-file="terraform.tfvars"
```

### 問題2: ECRプッシュでエラー

**症状**: `no basic auth credentials`

**原因**: ECRログインが期限切れ

**解決**:
```bash
# 再ログイン
aws ecr get-login-password --region ap-northeast-1 | \
  docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
```

### 問題3: ECSタスクが起動しない

**症状**: タスクが即座にSTOPPED状態になる

**原因**: イメージのプル失敗、環境変数の設定ミス

**解決**:
```bash
# タスクの詳細確認（stoppedReasonを確認）
aws ecs describe-tasks \
  --cluster srep1-dev-ecs-cluster \
  --tasks <task-arn> \
  --query 'tasks[0].stoppedReason'

# CloudWatch Logsで詳細確認
aws logs tail /aws/ecs/srep1-dev-api-python --follow
```

### 問題4: DB接続エラー

**症状**: `/dbtest` で「Database error」

**原因**: 
- Secrets Managerの認証情報が未設定
- db-inituserタスクが実行されていない

**解決**:
```bash
# Secrets Managerの確認
aws secretsmanager get-secret-value \
  --secret-id srep1-dev-rds-app-secret \
  --query SecretString --output text

# db-inituserタスクを手動実行
aws ecs run-task \
  --cluster srep1-dev-ecs-cluster \
  --task-definition srep1-dev-db-inituser-taskdef \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=ENABLED}"
```

---

## 📚 次のステップ

1. **独自ドメインの設定**: Route53でドメインを設定し、ACM証明書を取得
2. **WAFルールのカスタマイズ**: セキュリティ要件に応じてWAFルールを調整
3. **監視アラートの設定**: CloudWatch AlarmsとSNSで重要なメトリクスを監視
4. **バックアップ設定**: RDSの自動バックアップ設定を確認
5. **CI/CD改善**: GitHub Actionsワークフローにテスト・セキュリティスキャンを追加

---

**セットアップ中に問題が発生した場合は、メインREADME.mdの「お問い合わせ」セクションを参照してください。**

