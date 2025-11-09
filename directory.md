# プロジェクトディレクトリ構造

このドキュメントでは、SREP1プロジェクトの完全なディレクトリ構造を説明します。

---

## 📂 ルートディレクトリ

```
srep1/
├── README.md                    # プロジェクト概要（メイン）
├── QUICK_START.md               # クイックスタートガイド
├── SETUP.md                     # 詳細セットアップガイド
├── ARCHITECTURE.md              # アーキテクチャ詳細設計
├── FAQ.md                       # よくある質問
├── CHANGELOG.md                 # 変更履歴
├── LICENSE                      # MITライセンス
├── directory.md                 # このファイル
├── .gitignore                   # Git除外設定
├── .gitattributes               # Git属性設定
│
├── app/                         # アプリケーションコード
├── terraform/                   # Terraformコード
└── .github/                     # GitHub設定
```

---

## 📱 app/ - アプリケーション

```
app/
├── README.md                    # アプリケーション説明
│
├── front-nginx/                 # フロントエンド（Nginx）
│   ├── Dockerfile
│   ├── docker-entrypoint.sh
│   ├── default_template.conf   # Nginx設定テンプレート
│   ├── index.html              # メインHTML
│   ├── style.css               # スタイルシート
│   └── script.js               # JavaScriptロジック
│
├── api-python/                  # バックエンドAPI（Flask）
│   ├── Dockerfile
│   ├── app.py                  # メインアプリケーション
│   └── requirements.txt        # Python依存パッケージ
│
├── db-initdata/                 # DB初期データ投入
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── initdata.sql            # サンプルデータSQL
│
└── db-inituser/                 # DBユーザー作成
    ├── Dockerfile
    └── entrypoint.sh
```

---

## 🏗️ terraform/ - インフラストラクチャ

```
terraform/
├── README.md                    # Terraform説明書
├── DIRECTORY_STRUCTURE.md       # Terraform構造詳細
│
├── docs/                        # 詳細ドキュメント
│   └── nat-gateway-configuration-guide.md
│
├── environments/                # 環境別設定
│   ├── dev/                     # 開発環境
│   │   ├── main.tf             # メイン設定（モジュール呼び出し）
│   │   ├── variables.tf        # 変数定義
│   │   ├── terraform.tfvars    # 変数値（Git除外）
│   │   ├── terraform.tfvars.example  # 変数サンプル
│   │   ├── provider.tf         # AWSプロバイダー設定
│   │   ├── backend.tf          # S3バックエンド設定
│   │   └── outputs.tf          # 出力値定義
│   │
│   ├── stg/                     # ステージング環境
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── provider.tf
│   │   ├── backend.tf
│   │   └── outputs.tf
│   │
│   └── prod/                    # 本番環境
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── provider.tf
│       ├── backend.tf
│       └── outputs.tf
│
└── modules/                     # 再利用可能なモジュール（20以上）
    │
    ├── vpc/                     # VPC、サブネット、NAT Gateway
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── README.md
    │   └── README-NAT-Gateway-Specification.md
    │
    ├── sg/                      # セキュリティグループ
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    │
    ├── alb/                     # Application Load Balancer
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ecs/                     # ECS（Fargate）
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ecr/                     # Elastic Container Registry
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── rds/                     # Aurora MySQL
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── README.md
    │   └── README-Aurora-Configuration-Guide.md
    │
    ├── lambda/                  # Lambda（Secrets Managerローテーション）
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── src/
    │   │   ├── master_rotation_function.py
    │   │   ├── app_rotation_function.py
    │   │   ├── requirements.txt
    │   │   └── lib/            # pymysqlライブラリ
    │   └── output/             # ビルド済みLambda関数ZIP
    │       ├── master_lambda.zip
    │       └── app_lambda.zip
    │
    ├── secretsmanager/          # Secrets Manager
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── cloudwatch_logs/         # CloudWatch Logs
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── sns/                     # SNS トピック
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── chatbot/                 # AWS Chatbot
    │   └── outputs.tf
    │
    ├── waf/                     # AWS WAF
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    │
    ├── guardduty_cfn/           # GuardDuty（CloudFormation経由）
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── README.md
    │   └── templates/
    │       └── enable-guardduty-template.yml
    │
    ├── cloudtrail/              # CloudTrail
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── iam_role/                # IAMロール・ポリシー
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── output.tf
    │   └── iam_policy/         # カスタムポリシーJSON
    │       ├── CustomECSTaskExecutionPolicy.json
    │       ├── CustomECSTaskPolicy.json
    │       ├── CustomGitHubActionsPolicy.json
    │       ├── CustomMasterLambdaPolicy.json
    │       ├── CustomAppLambdaPolicy.json
    │       ├── CustomRDSEnhancedMonitoringPolicy.json
    │       ├── CustomCloudFormationStackSetAdministrationPolicy.json
    │       ├── CustomCloudFormationStackSetExecutionPolicy.json
    │       └── CustomQDeveloperPolicy.json
    │
    ├── route53_zone/            # Route53 ホストゾーン
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── route53_records/         # Route53 レコード
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── acm/                     # ACM証明書
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── eventbridge/             # EventBridge
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    │
    ├── cloudmap/                # Service Discovery
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── vpc_flow_logs/           # VPC Flow Logs
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── iam_accessanalyzer/      # IAM Access Analyzer
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── q_developer/             # Amazon Q Developer（オプション）
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    │
    └── s3/                      # S3バケット
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## 🔄 .github/ - CI/CD

```
.github/
└── workflows/                   # GitHub Actionsワークフロー
    ├── front-nginx.yml          # Nginxコンテナビルド・デプロイ
    ├── api-python.yml           # Flaskコンテナビルド・デプロイ
    ├── db-initdata.yml          # DB初期データコンテナビルド
    └── db-inituser.yml          # DBユーザー作成コンテナビルド
```

---

## 📊 ファイル統計

| カテゴリ | ファイル数 | 説明 |
|---------|-----------|------|
| **ドキュメント** | 10+ | README、SETUP、ARCHITECTURE等 |
| **Terraformモジュール** | 20+ | 各AWSサービスのモジュール |
| **アプリケーション** | 10+ | コンテナ、Dockerfileなど |
| **CI/CD** | 4 | GitHub Actionsワークフロー |
| **設定ファイル** | 10+ | 環境別tfvars、backend等 |

---

## 🎯 主要ファイルの役割

### プロジェクト理解に重要なファイル

1. **README.md** - 最初に読むべきファイル
2. **QUICK_START.md** - すぐに始めたい人向け
3. **ARCHITECTURE.md** - 設計思想を理解したい人向け
4. **terraform/environments/dev/main.tf** - インフラ構成の全体像
5. **app/api-python/app.py** - アプリケーションロジック

### 設定変更が必要なファイル

1. **terraform/environments/dev/backend.tf** - S3バケット名
2. **terraform/environments/dev/terraform.tfvars** - 環境固有の設定
3. **GitHub Secrets** - AWS認証情報（コードには含まれない）

---

## 🔍 ファイル検索のヒント

### 特定のリソースを探す

- **VPC設定**: `terraform/modules/vpc/`
- **ECS設定**: `terraform/modules/ecs/`
- **RDS設定**: `terraform/modules/rds/`
- **セキュリティグループ**: `terraform/modules/sg/`

### ドキュメントを探す

- **セットアップ方法**: `SETUP.md`、`QUICK_START.md`
- **トラブルシューティング**: `FAQ.md`
- **変更履歴**: `CHANGELOG.md`
- **モジュール詳細**: 各モジュールの`README.md`

---

## 📝 Git除外ファイル（.gitignore）

以下のファイルはGitで管理されません：

- `**/.terraform/` - Terraformプラグイン
- `**.tfstate` - Terraform状態ファイル
- `**.tfvars` - 環境固有の設定（機密情報含む可能性）
- `**/lib` - Pythonライブラリ
- `**/output` - ビルド成果物
- `*.log` - ログファイル

詳細は `.gitignore` を参照してください。

---

**このディレクトリ構造を理解することで、プロジェクト全体の把握が容易になります。** 