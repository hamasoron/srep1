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

## コミットメッセージの例
型（type）	スコープ（scope）	説明（description）	例文	用途・意味
feat	(省略可)	新機能の追加	feat: ユーザー登録機能を追加
feat(auth): パスワードリセット機能を追加	新しい機能追加
fix	(省略可)	バグ修正	fix: ログイン時のクラッシュを修正
fix(api): レスポンスの型ミスを修正	バグの修正
docs	(省略可)	ドキュメントの変更	docs: READMEの説明を更新	ドキュメントのみの変更
style	(省略可)	コードスタイルの変更	style: インデントを修正
style(api): セミコロン追加	機能変更を伴わない書式・スタイル修正
refactor	(省略可)	リファクタリング	refactor: 読みやすさ向上のためコード整理	挙動変更なしのリファクタリング
perf	(省略可)	パフォーマンス改善	perf: クエリの高速化	性能向上
test	(省略可)	テスト追加・修正	test: ユニットテスト追加	テストコード関連
build	(省略可)	ビルドシステムや依存関係の変更	build: webpack 設定を更新	ビルドツールや依存関係の変更
ci	(省略可)	CI/CD構成の変更	ci: GitHub Actionsを追加	CI/CDの設定変更
chore	(省略可)	その他雑多な作業	chore: 不要なファイルを削除	その他分類できない変更
revert	(省略可)	以前のコミットの取り消し	revert: feat(auth): パスワードリセット機能を追加の取り消し	コミットの取り消し
