# アプリケーション構成

このディレクトリには、ECS Fargateで実行される3つのコンテナアプリケーションが含まれています。

---

## 📦 コンテナ構成

### 1. front-nginx

**フロントエンドWebサーバー**

- **技術**: Nginx + HTML/CSS/JavaScript
- **ポート**: 80
- **役割**: 
  - 静的ファイルの配信
  - ALBからのトラフィックを受信
  - バックエンドAPIへのプロキシ

#### ファイル構成

```
front-nginx/
├── Dockerfile              # Nginxコンテナイメージ
├── docker-entrypoint.sh    # 起動時スクリプト
├── default_template.conf   # Nginx設定テンプレート
├── index.html              # メインHTML
├── style.css               # スタイルシート
└── script.js               # フロントエンドロジック
```

#### 機能

- **API接続テスト**: バックエンドAPIへの接続確認
- **DB接続テスト**: データベース経由のデータ取得確認
- **レスポンシブデザイン**: モバイル・デスクトップ対応

---

### 2. api-python

**バックエンドREST API**

- **技術**: Flask (Python)
- **ポート**: 8080
- **役割**:
  - REST APIエンドポイント提供
  - Aurora MySQLへの接続
  - ECS Service Discovery経由でフロントエンドから呼び出し

#### ファイル構成

```
api-python/
├── Dockerfile          # Flaskコンテナイメージ
├── app.py              # メインアプリケーション
└── requirements.txt    # Python依存パッケージ
```

#### エンドポイント

##### GET /
- **説明**: API接続テスト
- **レスポンス**: `API接続テストが成功しました`

##### GET /dbtest
- **説明**: データベース接続テスト
- **処理**:
  1. Secrets Managerから認証情報取得
  2. Aurora MySQL (Reader)に接続
  3. `aws_certifications`テーブルのレコード数を取得
- **レスポンス**: `DB接続テストが成功しました（aws_certifications の件数：X）`

#### 環境変数

| 変数名 | 説明 | 例 |
|--------|------|-----|
| `DB_APP_USERNAME` | アプリユーザー名 | `app_user` |
| `DB_APP_PASSWORD` | アプリユーザーパスワード | (Secrets Managerから取得) |
| `DB_READER_HOST` | RDS Readerエンドポイント | `srep1-dev-aurora-cluster.cluster-ro-xxxxx.ap-northeast-1.rds.amazonaws.com` |
| `DB_PORT` | データベースポート | `3306` |
| `DB_NAME` | データベース名 | `srep1db` |

---

### 3. db-initdata

**データベース初期データ投入**

- **技術**: MySQL Client + Shell Script
- **役割**:
  - 初回デプロイ時のテーブル作成
  - サンプルデータの投入
  - 一度実行後は終了

#### ファイル構成

```
db-initdata/
├── Dockerfile       # 初期化コンテナイメージ
├── entrypoint.sh    # 初期化スクリプト
└── initdata.sql     # 初期データSQLファイル
```

#### 初期データ (initdata.sql)

**aws_certifications テーブル**

| id | category | name | level | date_obtained |
|----|----------|------|-------|---------------|
| 1 | Cloud Practitioner | AWS Certified Cloud Practitioner | Foundational | 2022-01-15 |
| 2 | Architect | AWS Certified Solutions Architect – Associate | Associate | 2022-06-20 |
| 3 | SysOps | AWS Certified SysOps Administrator – Associate | Associate | 2023-03-10 |
| ... | ... | ... | ... | ... |

---

### 4. db-inituser

**データベースユーザー作成**

- **技術**: MySQL Client + Shell Script
- **役割**:
  - アプリケーション用ユーザーの作成
  - 権限設定
  - 一度実行後は終了

#### ファイル構成

```
db-inituser/
├── Dockerfile       # ユーザー作成コンテナイメージ
└── entrypoint.sh    # ユーザー作成スクリプト
```

---

## 🚀 ローカル開発

### 前提条件

- Docker Desktop
- Python 3.9以上
- MySQL Client（オプション）

### フロントエンド単体起動

```bash
cd app/front-nginx
docker build -t front-nginx:local .
docker run -p 8080:80 \
  -e API_ENDPOINT=http://localhost:8081 \
  front-nginx:local
```

ブラウザで `http://localhost:8080` にアクセス

### バックエンド単体起動

```bash
cd app/api-python

# 環境変数設定
export DB_APP_USERNAME=your_username
export DB_APP_PASSWORD=your_password
export DB_READER_HOST=your-aurora-endpoint.rds.amazonaws.com
export DB_PORT=3306
export DB_NAME=srep1db

# Dockerで起動
docker build -t api-python:local .
docker run -p 8081:8080 \
  -e DB_APP_USERNAME \
  -e DB_APP_PASSWORD \
  -e DB_READER_HOST \
  -e DB_PORT \
  -e DB_NAME \
  api-python:local
```

APIテスト:
```bash
curl http://localhost:8081/
curl http://localhost:8081/dbtest
```

---

## 🔄 デプロイフロー

### GitHub Actions による自動デプロイ

```
コード変更
    ↓
Git Push
    ↓
GitHub Actions トリガー
    ↓
1. 環境判定 (main → prod, staging → stg, develop → dev)
    ↓
2. Dockerイメージビルド
    ↓
3. ECRへプッシュ (タグ: commit SHA + latest)
    ↓
4. ECSタスク定義更新（自動 or 手動）
    ↓
5. ECSサービス再起動（自動 or 手動）
    ↓
デプロイ完了
```

### ワークフローファイル

- `front-nginx.yml`: フロントエンドのビルド・デプロイ
- `api-python.yml`: バックエンドのビルド・デプロイ
- `db-initdata.yml`: DB初期化コンテナのビルド
- `db-inituser.yml`: DBユーザー作成コンテナのビルド

---

## 🧪 動作確認

### ヘルスチェック

ALBのターゲットグループで設定されているヘルスチェック:

- **フロントエンド**: `GET /` (HTTP 200)
- **バックエンド**: `GET /` (HTTP 200)

### 手動テスト

```bash
# フロントエンド
curl -I https://your-alb-endpoint.ap-northeast-1.elb.amazonaws.com/

# バックエンド（内部アクセス）
curl http://api-python.srep1-service-discovery:8080/
curl http://api-python.srep1-service-discovery:8080/dbtest
```

---

## 🐛 トラブルシューティング

### 問題1: API接続エラー

**症状**: フロントエンドから「API接続に失敗しました」

**原因**:
- セキュリティグループでポート8080が許可されていない
- Service Discoveryの名前解決失敗
- バックエンドコンテナが起動していない

**解決**:
```bash
# ECSタスクの確認
aws ecs list-tasks --cluster srep1-dev-ecs-cluster
aws ecs describe-tasks --cluster srep1-dev-ecs-cluster --tasks <task-arn>

# ログ確認
aws logs tail /aws/ecs/srep1-dev-api-python --follow
```

### 問題2: DB接続エラー

**症状**: `/dbtest` で「Database error」

**原因**:
- Secrets Managerの認証情報が誤っている
- セキュリティグループでRDSポート3306が許可されていない
- RDSエンドポイントが誤っている

**解決**:
```bash
# Secrets Manager確認
aws secretsmanager get-secret-value --secret-id srep1-dev-rds-app-secret

# セキュリティグループ確認
aws ec2 describe-security-groups --group-ids <sg-id>

# RDSエンドポイント確認
aws rds describe-db-cluster-endpoints --db-cluster-identifier srep1-dev-aurora-cluster
```

### 問題3: コンテナ起動失敗

**症状**: ECSタスクが即座に停止する

**原因**:
- イメージのプル失敗
- 環境変数の設定ミス
- コンテナ内エラー

**解決**:
```bash
# ECS Execでコンテナ内確認
aws ecs execute-command \
  --cluster srep1-dev-ecs-cluster \
  --task <task-id> \
  --container api-python \
  --command "/bin/bash" \
  --interactive

# CloudWatch Logsで詳細確認
aws logs get-log-events \
  --log-group-name /aws/ecs/srep1-dev-api-python \
  --log-stream-name <stream-name>
```

---

## 📚 参考資料

- [Flask公式ドキュメント](https://flask.palletsprojects.com/)
- [Nginx公式ドキュメント](https://nginx.org/en/docs/)
- [ECS Fargate ベストプラクティス](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [Service Discovery](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/service-discovery.html)

---

**質問や問題がある場合は、プロジェクトのメインREADME.mdまたはTerraformドキュメントを参照してください。**

