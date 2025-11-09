# AWS ECS Webアプリケーション - Terraform × GitHub Actions

[![AWS](https://img.shields.io/badge/AWS-ECS%20%7C%20Fargate%20%7C%20Aurora-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-844FBA?logo=terraform)](https://www.terraform.io/)
[![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions)](https://github.com/features/actions)

**Terraform + GitHub ActionsによるフルマネージドなWebアプリケーション基盤の構築と運用自動化**

オンプレミスからAWSへの移行経験を活かし、モダンなIaC/CI/CD環境を0から設計・実装したポートフォリオプロジェクトです。

---

## 📖 目次

- [プロジェクト概要](#-プロジェクト概要)
- [アーキテクチャ](#-アーキテクチャ)
- [主な技術スタック](#-主な技術スタック)
- [実装した機能・工夫点](#-実装した機能工夫点)
- [ディレクトリ構成](#-ディレクトリ構成)
- [セットアップ手順](#-セットアップ手順)
- [CI/CDパイプライン](#-cicdパイプライン)
- [運用・監視](#-運用監視)
- [コスト最適化](#-コスト最適化)
- [実績・成果](#-実績成果)

---

## 🎯 プロジェクト概要

このプロジェクトは、**実務で培ったAWS移行・IaC化・CI/CD構築のノウハウを凝縮**したポートフォリオです。

### 背景・目的

- オンプレミス環境からAWSへの移行プロジェクト経験（2件）を活かし、ベストプラクティスを実装
- Terraformによるモジュール化・環境分離により、**構築工数60%削減**を実現
- GitHub Actionsによる完全自動化されたCI/CDパイプライン構築

### アプリケーション

シンプルなWebアプリケーション（AWS認定資格表示サイト）

- **フロントエンド**: HTML/CSS/JavaScript + Nginx
- **バックエンド**: Flask (Python) REST API
- **データベース**: Aurora MySQL（Reader/Writer分離）
- **API機能**: ECS接続テスト、DB接続テスト

---

## 🏗️ アーキテクチャ

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                    ┌────▼────┐
                    │   WAF   │  ← セキュリティ保護
                    └────┬────┘
                         │
                    ┌────▼────┐
                    │   ALB   │  ← ロードバランシング
                    └────┬────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   ┌────▼────┐      ┌────▼────┐     ┌────▼────┐
   │  ECS    │      │  ECS    │     │  ECS    │
   │ (Nginx) │──────│ (Flask) │     │ (DB初期化)│
   │ Fargate │      │ Fargate │     │  Fargate │
   └─────────┘      └────┬────┘     └─────────┘
                         │
                    ┌────▼──────────┐
                    │ Aurora MySQL  │
                    │ (Multi-AZ)    │
                    │ Writer/Reader │
                    └───────────────┘
                    
┌─────────────────────────────────────────────────────────────────┐
│  監視・セキュリティ                                               │
├─────────────────────────────────────────────────────────────────┤
│ CloudWatch Logs/Alarms | GuardDuty | CloudTrail | SNS/Chatbot  │
│ Secrets Manager (自動ローテーション) | IAM Access Analyzer       │
└─────────────────────────────────────────────────────────────────┘
```

### ネットワーク構成

- **VPC**: マルチAZ対応（2AZ/3AZ選択可能）
- **サブネット**: Public/Private構成
- **NAT Gateway**: 環境別に冗長構成可能
- **セキュリティグループ**: 最小権限の原則に基づいた設計

---

## 🛠️ 主な技術スタック

### インフラストラクチャ

| カテゴリ | 技術 | 用途 |
|---------|------|------|
| **IaC** | Terraform (HCL) | インフラのコード化・モジュール化 |
| **コンピューティング** | ECS Fargate | コンテナ実行環境 |
| **データベース** | Aurora MySQL | マネージドRDBMS（Multi-AZ） |
| **ネットワーク** | VPC, ALB, Route53 | ネットワーク基盤・ロードバランシング |
| **セキュリティ** | WAF, Secrets Manager, GuardDuty | セキュリティ保護・認証情報管理 |
| **監視** | CloudWatch (Logs/Alarms) | ログ集約・メトリクス監視・アラート |
| **通知** | SNS, AWS Chatbot | アラート通知 |

### CI/CD・開発

| カテゴリ | 技術 | 用途 |
|---------|------|------|
| **CI/CD** | GitHub Actions | 自動ビルド・デプロイパイプライン |
| **コンテナレジストリ** | ECR | Dockerイメージ管理 |
| **バックエンド** | Python (Flask) | REST API |
| **フロントエンド** | HTML/CSS/JavaScript, Nginx | Webサーバー |

### AWS主要サービス

- **コンピューティング**: ECS, Fargate, Lambda
- **ネットワーク**: VPC, ALB, Route53, CloudMap
- **データベース**: Aurora MySQL (Multi-AZ)
- **ストレージ**: S3 (Terraform State管理)
- **セキュリティ**: WAF, Secrets Manager, GuardDuty, IAM Access Analyzer, CloudTrail
- **監視・通知**: CloudWatch, SNS, EventBridge, Chatbot

---

## 💡 実装した機能・工夫点

### 1. Terraformによる完全なIaC化

#### モジュール設計
- **再利用可能なモジュール**: 20以上のAWSサービスをモジュール化
- **環境分離**: dev/stg/prod環境の独立管理
- **変数化・パラメータ化**: 環境別の柔軟な設定変更

```hcl
terraform/
├── modules/          # 再利用可能なモジュール
│   ├── vpc/
│   ├── ecs/
│   ├── rds/
│   ├── alb/
│   └── ... (20+ modules)
└── environments/     # 環境別設定
    ├── dev/
    ├── stg/
    └── prod/
```

#### 既存リソースのコード化
- `terraform import`を活用した既存リソースの取り込み
- 手動構築からコード管理への移行実現

### 2. 環境別最適化

#### Aurora MySQL
- **dev環境**: 1台構成（コスト最優先）
- **stg環境**: 2台構成（Writer + Reader）
- **prod環境**: 2台/3台選択可能（高可用性重視）

#### NAT Gateway
- 環境別に有効/無効を制御
- コストと可用性のバランス調整

### 3. セキュリティ対策

#### 多層防御
- **WAF**: SQLインジェクション、XSS対策
- **セキュリティグループ**: 最小権限の原則
- **GuardDuty**: 脅威検知
- **CloudTrail**: 操作ログ記録
- **IAM Access Analyzer**: 過剰な権限の検出

#### 認証情報管理
- **Secrets Manager**: RDS認証情報の安全な管理
- **Lambda自動ローテーション**: マスターユーザーとアプリケーションユーザーの自動ローテーション
- パスワードの定期的な更新自動化

### 4. 監視・可観測性

#### ログ管理
- **CloudWatch Logs**: 各コンテナ・RDSのログ集約
- **VPC Flow Logs**: ネットワークトラフィック監視

#### アラート通知
- **CloudWatch Alarms**: CPU使用率、メモリ、コネクション数などの監視
- **SNS + AWS Chatbot**: リアルタイム通知（Slack/Teams連携可能）

### 5. CI/CDパイプライン

#### 自動化フロー
1. **コード変更検知**: Gitプッシュ時に自動トリガー
2. **イメージビルド**: Docker Buildx使用
3. **ECRプッシュ**: タグ付けされたイメージの自動アップロード
4. **ECSデプロイ**: タスク定義更新とサービス再起動
5. **ヘルスチェック**: デプロイ後の自動確認

#### ブランチ戦略
- `main`: 本番環境（prod）
- `stg`: ステージング環境
- `dev`: 開発環境

### 6. コスト最適化

#### リソース配置の最適化
- **dev環境**: NAT Gateway 1台、Aurora 1台 → 月額 $100-150
- **stg環境**: NAT Gateway 2台、Aurora 2台 → 月額 $200-300
- **prod環境**: フル冗長構成 → 月額 $350-500

#### Fargate Spot活用（オプション）
- 開発環境でSpotインスタンス活用による最大70%コスト削減

---

## 📁 ディレクトリ構成

```
.
├── app/                      # アプリケーションコード
│   ├── front-nginx/          # フロントエンド (Nginx + HTML/CSS/JS)
│   │   ├── Dockerfile
│   │   ├── index.html
│   │   ├── style.css
│   │   └── script.js
│   ├── api-python/           # バックエンド (Flask)
│   │   ├── Dockerfile
│   │   ├── app.py
│   │   └── requirements.txt
│   ├── db-initdata/          # DB初期データ投入
│   │   ├── Dockerfile
│   │   ├── entrypoint.sh
│   │   └── initdata.sql
│   └── db-inituser/          # DBユーザー作成
│       ├── Dockerfile
│       └── entrypoint.sh
│
├── terraform/                # Terraformコード
│   ├── modules/              # 再利用可能なモジュール
│   │   ├── vpc/              # VPC・サブネット・NAT Gateway
│   │   ├── sg/               # セキュリティグループ
│   │   ├── alb/              # Application Load Balancer
│   │   ├── ecs/              # ECSクラスター・サービス・タスク定義
│   │   ├── ecr/              # Elastic Container Registry
│   │   ├── rds/              # Aurora MySQL
│   │   ├── lambda/           # Lambda（Secrets Managerローテーション）
│   │   ├── secretsmanager/   # Secrets Manager
│   │   ├── cloudwatch_logs/  # CloudWatch Logs
│   │   ├── sns/              # SNS トピック
│   │   ├── chatbot/          # AWS Chatbot
│   │   ├── waf/              # AWS WAF
│   │   ├── guardduty_cfn/    # GuardDuty (CloudFormation経由)
│   │   ├── cloudtrail/       # CloudTrail
│   │   ├── iam_role/         # IAMロール・ポリシー
│   │   ├── route53_zone/     # Route53 ホストゾーン
│   │   ├── route53_records/  # Route53 レコード
│   │   ├── acm/              # ACM証明書
│   │   └── eventbridge/      # EventBridge
│   │
│   ├── environments/         # 環境別設定
│   │   ├── dev/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── terraform.tfvars
│   │   │   ├── provider.tf
│   │   │   ├── backend.tf
│   │   │   └── outputs.tf
│   │   ├── stg/
│   │   └── prod/
│   │
│   ├── docs/                 # 詳細ドキュメント
│   └── README.md             # Terraform説明書
│
├── .github/
│   └── workflows/            # GitHub Actionsワークフロー
│       ├── front-nginx.yml   # Nginxコンテナビルド・デプロイ
│       ├── api-python.yml    # Flaskコンテナビルド・デプロイ
│       └── db-init.yml       # DB初期化コンテナビルド
│
├── README.md                 # このファイル
└── directory.md              # ディレクトリ構造詳細
```

---

## 🚀 セットアップ手順

### 前提条件

- AWSアカウント
- Terraform 1.5以上
- AWS CLI設定済み
- GitHub アカウント

### 1. リポジトリのクローン

```bash
git clone https://github.com/your-username/srep1.git
cd srep1
```

### 2. Terraform設定

#### S3バケット作成（tfstate保存用）

```bash
aws s3 mb s3://your-terraform-state-bucket --region ap-northeast-1
```

#### backend.tf編集

```hcl
# terraform/environments/dev/backend.tf
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
```

#### terraform.tfvars編集

```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # 環境に応じて編集
```

### 3. インフラ構築

```bash
# 初期化
terraform init

# プラン確認
terraform plan -var-file="terraform.tfvars"

# 適用
terraform apply -var-file="terraform.tfvars"
```

### 4. GitHub Actionsシークレット設定

GitHub リポジトリの Settings > Secrets and variables > Actions で以下を設定:

```
AWS_ACCESS_KEY_ID          # IAMユーザーのアクセスキー
AWS_SECRET_ACCESS_KEY      # IAMユーザーのシークレットキー
AWS_REGION                 # ap-northeast-1
ECR_REGISTRY              # xxxxx.dkr.ecr.ap-northeast-1.amazonaws.com
ECS_CLUSTER_NAME          # srep1-dev-ecs-cluster
```

### 5. 初回デプロイ

```bash
# mainブランチにプッシュしてCI/CDトリガー
git add .
git commit -m "Initial deployment"
git push origin main
```

---

## 🔄 CI/CDパイプライン

### ワークフロー概要

GitHub Actionsによる完全自動化されたデプロイパイプライン

#### front-nginx.yml（フロントエンド）

```yaml
トリガー: app/front-nginx/ 配下の変更
↓
1. Dockerイメージビルド
↓
2. ECRプッシュ (srep1-front-nginx:latest)
↓
3. ECSタスク定義更新
↓
4. ECSサービス再起動
↓
5. デプロイ完了
```

#### api-python.yml（バックエンド）

```yaml
トリガー: app/api-python/ 配下の変更
↓
1. Dockerイメージビルド
↓
2. ECRプッシュ (srep1-api-python:latest)
↓
3. ECSタスク定義更新
↓
4. ECSサービス再起動
↓
5. デプロイ完了
```

### 環境別デプロイ

| ブランチ | 環境 | デプロイタイミング |
|---------|------|------------------|
| `dev` | 開発環境 | プッシュ時に自動 |
| `stg` | ステージング | プッシュ時に自動 |
| `main` | 本番環境 | プッシュ時に自動 |

---

## 📊 運用・監視

### CloudWatch監視項目

#### ECS Fargate
- CPU使用率（閾値: 80%）
- メモリ使用率（閾値: 80%）
- タスク実行数

#### Aurora MySQL
- CPU使用率（閾値: 80%）
- コネクション数（閾値: 100）
- レプリケーションラグ（閾値: 1000ms）
- ストレージ容量

#### ALB
- ターゲットヘルスチェック
- レスポンスタイム
- HTTPステータスコード（4xx/5xx）

### アラート通知

- **SNS**: メール通知
- **AWS Chatbot**: Slack/Microsoft Teams連携

### ログ管理

- **CloudWatch Logs**: 各サービスのログ集約
  - `/aws/ecs/srep1-front-nginx`
  - `/aws/ecs/srep1-api-python`
  - `/aws/rds/cluster/srep1-aurora-cluster`
- **保持期間**: 30日（環境により調整可能）

---

## 💰 コスト最適化

### 環境別コスト概算

| 環境 | 主要リソース | 月額概算 |
|------|------------|---------|
| **dev** | Fargate 2台、Aurora 1台、NAT 1台 | $100-150 |
| **stg** | Fargate 2台、Aurora 2台、NAT 2台 | $200-300 |
| **prod** | Fargate 3台、Aurora 3台、NAT 3台 | $350-500 |

### コスト削減施策

1. **環境別リソース最適化**
   - dev環境: 単一AZ構成
   - stg環境: 2AZ構成
   - prod環境: フル冗長構成

2. **不要時のリソース停止**
   ```bash
   # 開発環境の一時停止（夜間・週末）
   terraform destroy -target=module.ecs
   ```

3. **Fargate Spotの活用**（オプション）
   - 開発環境で最大70%コスト削減

4. **S3ライフサイクル設定**
   - ログの自動アーカイブ・削除

---

## 🎖️ 実績・成果

### 本プロジェクトで達成したこと

#### 1. 構築工数の大幅削減
- **手動構築**: 約20時間 → **Terraform**: 約8時間（60%削減）
- 環境複製がコマンド1つで完了

#### 2. デプロイ時間の短縮
- **手動デプロイ**: 約30分 → **CI/CD**: 約5分（83%短縮）
- 人的ミスの排除

#### 3. 運用効率の向上
- **MTTR（平均復旧時間）**: 5〜10分短縮
- CloudWatch監視基盤により、問題の早期検知

#### 4. 属人化の排除
- IaC化により、誰でも同じ環境を構築可能
- ドキュメント整備による引き継ぎコスト削減

### 実務での応用実績

実務プロジェクトにおいて、本ポートフォリオで培った技術を活用:

- **AWS移行プロジェクト2件を主導**
  - オンプレ → AWS移行（ALB + ECS/Fargate + RDS）
  - EOLサーバ群のAWS移行と標準化
  
- **Terraform + GitHub ActionsによるIaC/CI/CD基盤構築**
  - モジュール化設計、環境分離
  - 既存リソースのコード化（terraform import活用）
  - 構築工数を約60%削減
  
- **技術選定・アーキテクチャ判断**
  - アプリチームとの折衝によるログ収集方式の選定
  - コスト・運用性を考慮した技術判断

---

## 📚 ドキュメント一覧

### 🚀 スタートガイド
- **[QUICK_START.md](./QUICK_START.md)** - 5ステップで始める最短セットアップ（約40分）
- **[SETUP.md](./SETUP.md)** - 詳細なセットアップガイド（すべての手順を網羅）

### 📖 技術ドキュメント
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - アーキテクチャ詳細設計（システム構成図、セキュリティ設計）
- **[app/README.md](./app/README.md)** - アプリケーション構成とAPI仕様
- **[terraform/README.md](./terraform/README.md)** - Terraform詳細説明（モジュール設計）
- **[directory.md](./directory.md)** - プロジェクト完全ディレクトリ構造

### ❓ サポート
- **[FAQ.md](./FAQ.md)** - よくある質問と回答（20以上のQ&A）
- **[CHANGELOG.md](./CHANGELOG.md)** - 変更履歴とバージョン情報

### 📄 その他
- **[LICENSE](./LICENSE)** - MITライセンス

---

## 📝 ライセンス

このプロジェクトはポートフォリオ目的で作成されています。

---

## 👤 作成者

**インフラエンジニア | SREエンジニア志望**

- **実務経験**: インフラエンジニア 4年半
- **専門領域**: AWS、Terraform、CI/CD、監視・運用自動化

### 保有資格

**AWS認定資格**
- AWS Certified Solutions Architect – Associate (SAA)
- AWS Certified SysOps Administrator – Associate (SOA)
- AWS Certified Developer – Associate (DVA)
- AWS Certified Data Engineer – Associate (DEA)
- AWS Certified Cloud Practitioner (CLF)

**ネットワーク/Linux**
- CCNA (Cisco Certified Network Associate)
- LinuC レベル3 (304：仮想化・高可用性)
- LinuC レベル2
- LinuC レベル1

**その他**
- 情報セキュリティマネジメント試験
- ITパスポート試験

### 表彰実績
- **社長賞受賞（2023年）**: ネットワーク拠点拡大プロジェクトにて、品質・納期高水準で完遂

---

## 📧 お問い合わせ

ご質問やフィードバックがございましたら、お気軽にお問い合わせください。

---

**このプロジェクトが参考になりましたら、⭐️スターをいただけると嬉しいです！**

