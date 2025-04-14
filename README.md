# srep1 - AWSバックエンド/フロントエンド構成サンプル

## プロジェクト概要
srep1は、AWS上でマイクロサービスアーキテクチャを実装したサンプルプロジェクトです。このプロジェクトは次の3つの主要コンポーネントで構成されています：

- API（Python/Flask）
- フロントエンド（HTML/CSS/JavaScript + Nginx）
- データベース初期化（MySQL）

## ディレクトリ構造

```
srep1/
├── api-python/          # Python/Flaskバックエンド
│   ├── app.py           # APIアプリケーションコード
│   ├── Dockerfile       # APIコンテナ定義
│   └── requirements.txt # Pythonの依存関係
├── front-nginx/         # フロントエンドWebサーバー
│   ├── default.conf     # Nginx設定
│   ├── Dockerfile       # フロントエンドコンテナ定義
│   ├── index.html       # メインHTML
│   ├── script.js        # フロントエンドロジック
│   └── style.css        # スタイル定義
├── db-init/             # データベース初期化
│   ├── Dockerfile       # DBコンテナ定義
│   └── init.sql         # 初期化SQL
└── *.taskdef.json       # ECSタスク定義ファイル
```

## システム構成
このプロジェクトはAWS ECS Fargateを使用して、3つのコンテナを実行します：
1. **api-python**: FlaskベースのREST APIサーバー
2. **front-nginx**: ユーザーインターフェースとNginxウェブサーバー
3. **db-init**: Aurora MySQLデータベースの初期化

## 機能
- AWS認定資格情報の表示
- API接続テスト
- データベース接続テスト

## 開発環境のセットアップ
各ディレクトリには、対応するDockerfileがあり、開発環境をすばやく構築することができます。

## デプロイ
タスク定義ファイル（taskdef.json）を使用して、AWS ECS Fargateにデプロイします。

### 初回デプロイ手順
初回デプロイでは、以下の手順に従ってください：

1. Terraformでインフラをデプロイします。
   ```
   cd terraform/environments/[環境名]
   terraform init
   terraform apply
   ```

2. 初回のTerraform適用では、ECSサービスのdesired_countは0に設定されています。これは、初めてECRにイメージがプッシュされるまでECSタスクが起動しないようにするためです。

3. GitHub Actionsを実行して、コンテナイメージをECRにプッシュします。
   - mainブランチにプッシュするか、手動でワークフローを実行します。

4. イメージがECRにプッシュされたら、Terraformの変数を更新します：
   - `terraform.tfvars`ファイルでdesired_countを1に更新します。
   - または、AWS Management ConsoleからECSサービスを編集し、タスク数を1に変更します。

5. 更新後のTerraformを適用します：
   ```
   terraform apply
   ```

これにより、ECRにイメージが存在する状態でECSサービスが起動するため、エラーを回避できます。

## ライセンス
このプロジェクトはサンプル用途として提供されています。
