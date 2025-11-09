# クイックスタートガイド

**5ステップで始められる！SREP1プロジェクトの最短セットアップガイド**

---

## ⚡ 所要時間

- **準備**: 10分
- **インフラ構築**: 20分
- **アプリデプロイ**: 10分
- **合計**: 約40分

---

## 📋 事前準備チェックリスト

以下が揃っているか確認してください：

- [ ] AWSアカウント（管理者権限）
- [ ] AWS CLI インストール済み & 設定済み
- [ ] Terraform 1.5以上 インストール済み
- [ ] Docker Desktop インストール済み
- [ ] GitHubアカウント

---

## 🚀 5ステップでデプロイ

### Step 1: リポジトリのフォーク/クローン（2分）

```bash
# GitHubでフォーク後、クローン
git clone https://github.com/YOUR_USERNAME/srep1.git
cd srep1
```

---

### Step 2: AWS準備（5分）

#### 2-1. AWS CLI設定確認
```bash
aws sts get-caller-identity
```

#### 2-2. Terraform State用S3バケット作成
```bash
export TF_STATE_BUCKET="srep1-tfstate-$(date +%s)"

aws s3 mb s3://${TF_STATE_BUCKET} --region ap-northeast-1

aws s3api put-bucket-versioning \
  --bucket ${TF_STATE_BUCKET} \
  --versioning-configuration Status=Enabled
```

#### 2-3. GitHub Actions用IAMロール作成（OIDC）

```bash
# アカウントIDとGitHubユーザー名を設定
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export GITHUB_USERNAME="your-github-username"

# OIDCプロバイダー作成
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# Trust Policy作成
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

# ポリシーアタッチ（簡略化 - 本番では最小権限を推奨）
aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# ロールARNをメモ
aws iam get-role --role-name GitHubActionsRole --query 'Role.Arn' --output text
```

---

### Step 3: GitHub Secrets設定（3分）

GitHubリポジトリの `Settings` > `Secrets and variables` > `Actions` で設定:

| シークレット名 | 値 |
|---------------|-----|
| `AWS_ROLE_TO_ASSUME` | `arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubActionsRole` |

---

### Step 4: Terraformでインフラ構築（20分）

#### 4-1. backend.tf編集

```bash
cd terraform/environments/dev
vim backend.tf
```

```hcl
terraform {
  backend "s3" {
    bucket = "your-bucket-name-here"  # Step 2で作成したバケット名
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
```

#### 4-2. terraform.tfvars作成

```bash
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

**最小限の設定（そのまま使用可能）:**
```hcl
region_name      = "ap-northeast-1"
system_name      = "srep1"
environment_name = "dev"

vpc_cidr_block = "10.0.0.0/16"

subnet_list = [
  { name = "1a", cidr_block = "10.0.64.0/24", type = "public" },
  { name = "1a", cidr_block = "10.0.0.0/24", type = "private" },
  { name = "1c", cidr_block = "10.0.65.0/24", type = "public" },
  { name = "1c", cidr_block = "10.0.1.0/24", type = "private" },
]

nat_gateway_list = [
  { az = "1a", enabled = true },
  { az = "1c", enabled = false },  # コスト削減のため1台のみ
]

use_all_azs_for_aurora = false  # dev環境は1台構成

db_master_username = "admin"
db_name            = "srep1db"
```

#### 4-3. Terraform実行

```bash
# 初期化
terraform init

# プラン確認（5分）
terraform plan -var-file="terraform.tfvars"

# 適用（15-20分）
terraform apply -var-file="terraform.tfvars" -auto-approve
```

**☕ コーヒーブレイク（15分）**

#### 4-4. 出力値を確認

```bash
terraform output
```

重要な出力値:
- `alb_dns_name`: ALBのDNS名（後で使用）
- `ecr_repositories`: ECRリポジトリURL

---

### Step 5: アプリケーションデプロイ（10分）

#### 5-1. ECRログイン

```bash
cd ../../../  # プロジェクトルートに戻る

aws ecr get-login-password --region ap-northeast-1 | \
  docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
```

#### 5-2. 初回イメージプッシュ

**フロントエンド:**
```bash
cd app/front-nginx
docker build -t srep1-dev-front-nginx:latest .
docker tag srep1-dev-front-nginx:latest \
  ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/srep1-dev-front-nginx-repo:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/srep1-dev-front-nginx-repo:latest
```

**バックエンド:**
```bash
cd ../api-python
docker build -t srep1-dev-api-python:latest .
docker tag srep1-dev-api-python:latest \
  ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/srep1-dev-api-python-repo:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/srep1-dev-api-python-repo:latest
```

**DB初期化:**
```bash
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

#### 5-3. ECSタスクの起動確認（3-5分）

```bash
# タスク一覧確認
aws ecs list-tasks --cluster srep1-dev-ecs-cluster

# タスク状態確認
aws ecs describe-tasks \
  --cluster srep1-dev-ecs-cluster \
  --tasks $(aws ecs list-tasks --cluster srep1-dev-ecs-cluster --query 'taskArns[0]' --output text) \
  --query 'tasks[0].lastStatus'
```

**RUNNING** が表示されればOK！

---

## 🎉 動作確認

### ブラウザでアクセス

```bash
# ALBのDNS名を取得
cd terraform/environments/dev
terraform output alb_dns_name
```

ブラウザで以下にアクセス:
```
http://<ALB_DNS_NAME>/
```

### テスト実行

1. **API接続テスト**ボタンをクリック
   - 「API接続テストが成功しました」が表示される ✅

2. **DB接続テスト**ボタンをクリック
   - 「DB接続テストが成功しました（件数: X）」が表示される ✅

---

## 🔄 次のステップ

### GitHub Actionsで自動デプロイ

以降は、コードをプッシュするだけで自動デプロイされます：

```bash
cd ../../../../  # プロジェクトルートに戻る

# 変更をコミット
git add .
git commit -m "Initial deployment"

# プッシュ（GitHub Actionsが自動実行）
git push origin main
```

GitHub リポジトリの `Actions` タブでワークフローの進捗を確認できます。

---

## 🧹 環境削除（テスト後）

コストを抑えるため、テスト後は必ずリソースを削除してください：

```bash
cd terraform/environments/dev

# 削除実行（15分）
terraform destroy -var-file="terraform.tfvars" -auto-approve
```

**手動削除が必要:**
- S3バケット（tfstate）
  ```bash
  aws s3 rm s3://${TF_STATE_BUCKET} --recursive
  aws s3 rb s3://${TF_STATE_BUCKET}
  ```

- ECRイメージ
  ```bash
  # リポジトリ削除（全イメージ含む）
  aws ecr delete-repository \
    --repository-name srep1-dev-front-nginx-repo \
    --force
  aws ecr delete-repository \
    --repository-name srep1-dev-api-python-repo \
    --force
  aws ecr delete-repository \
    --repository-name srep1-dev-db-initdata-repo \
    --force
  aws ecr delete-repository \
    --repository-name srep1-dev-db-inituser-repo \
    --force
  ```

---

## 💡 トラブルシューティング

### エラー: "no basic auth credentials"
**解決**: ECRに再ログイン
```bash
aws ecr get-login-password --region ap-northeast-1 | \
  docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
```

### エラー: "timeout while waiting for state"
**解決**: RDSの起動待ち（10-15分かかる場合があります）
```bash
aws rds describe-db-clusters \
  --db-cluster-identifier srep1-dev-aurora-cluster \
  --query 'DBClusters[0].Status'
```

### エラー: "InvalidRepositoryException"
**解決**: ECRリポジトリが作成されていない
```bash
cd terraform/environments/dev
terraform apply -target=module.ecr -var-file="terraform.tfvars"
```

### タスクが起動しない
**解決**: CloudWatch Logsで詳細確認
```bash
aws logs tail /aws/ecs/srep1-dev-api-python --follow
```

---

## 📚 詳細ドキュメント

さらに詳しく知りたい方は、以下のドキュメントをご覧ください：

- [README.md](./README.md) - プロジェクト全体の説明
- [SETUP.md](./SETUP.md) - 詳細なセットアップガイド
- [ARCHITECTURE.md](./ARCHITECTURE.md) - アーキテクチャ設計
- [FAQ.md](./FAQ.md) - よくある質問
- [terraform/README.md](./terraform/README.md) - Terraform詳細

---

## 🎯 成功のヒント

1. **環境変数をメモ**: `AWS_ACCOUNT_ID`、`TF_STATE_BUCKET`などはメモしておく
2. **ログを確認**: エラー時は必ずCloudWatch Logsを確認
3. **コスト管理**: 使わない時はリソース削除
4. **バージョン確認**: Terraform、AWS CLIのバージョンを確認

---

**おめでとうございます！🎉 これで完全なAWS環境が構築されました。**

次は実際にアプリケーションをカスタマイズして、自分だけのポートフォリオを作成しましょう！

