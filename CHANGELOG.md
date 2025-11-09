# 変更履歴

このプロジェクトに対するすべての重要な変更を記録します。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいています。

---

## [Unreleased]

### 今後の予定
- [ ] CloudFrontの統合（CDN）
- [ ] Aurora Serverless v2対応
- [ ] Fargate Spot対応
- [ ] マルチリージョン構成オプション
- [ ] Terraformテストフレームワーク（Terratest）の導入

---

## [1.0.0] - 2025-11-09

### 追加
- 📚 **ドキュメント整備**
  - メインREADME.md作成
  - SETUP.md（セットアップガイド）作成
  - ARCHITECTURE.md（アーキテクチャ詳細）作成
  - FAQ.md（よくある質問）作成
  - app/README.md（アプリケーション説明）作成
  - CHANGELOG.md（変更履歴）作成
  - LICENSE（MITライセンス）追加

- 🏗️ **インフラストラクチャ**
  - VPCモジュール（Multi-AZ対応）
  - ECS Fargateクラスター
  - Aurora MySQL（Writer + Reader構成）
  - Application Load Balancer
  - WAF（Web Application Firewall）
  - NAT Gateway（環境別に有効/無効切り替え可能）

- 🔐 **セキュリティ**
  - Secrets Manager（RDS認証情報管理）
  - Lambda（自動ローテーション機能）
  - GuardDuty（脅威検知）
  - CloudTrail（API操作ログ）
  - IAM Access Analyzer
  - セキュリティグループ（最小権限）

- 📊 **監視・ログ**
  - CloudWatch Logs（ECS、RDS、VPC Flow Logs）
  - CloudWatch Alarms（CPU、メモリ、接続数など）
  - SNS（アラート通知）
  - AWS Chatbot（Slack/Teams連携準備）

- 🔄 **CI/CD**
  - GitHub Actions ワークフロー
    - front-nginx.yml（フロントエンドデプロイ）
    - api-python.yml（バックエンドデプロイ）
    - db-initdata.yml（DB初期データ投入）
    - db-inituser.yml（DBユーザー作成）
  - OIDC認証（IAMユーザー不要）
  - 環境別デプロイ（dev/stg/prod）

- 📱 **アプリケーション**
  - フロントエンド（Nginx + HTML/CSS/JS）
  - バックエンドAPI（Flask）
  - データベース初期化スクリプト
  - API接続テスト機能
  - DB接続テスト機能

- 🛠️ **Terraformモジュール**（20以上）
  - vpc - VPC、サブネット、NAT Gateway
  - sg - セキュリティグループ
  - alb - Application Load Balancer
  - ecs - ECSクラスター、サービス、タスク定義
  - ecr - Elastic Container Registry
  - rds - Aurora MySQL
  - lambda - Secrets Managerローテーション
  - secretsmanager - Secrets Manager
  - cloudwatch_logs - CloudWatch Logs
  - sns - SNS トピック
  - chatbot - AWS Chatbot
  - waf - AWS WAF
  - guardduty_cfn - GuardDuty
  - cloudtrail - CloudTrail
  - iam_role - IAMロール・ポリシー
  - route53_zone - Route53 ホストゾーン
  - route53_records - Route53 レコード
  - acm - ACM証明書
  - eventbridge - EventBridge
  - cloudmap - Service Discovery
  - vpc_flow_logs - VPC Flow Logs
  - iam_accessanalyzer - IAM Access Analyzer
  - q_developer - Amazon Q Developer（オプション）

### 変更
- 🔧 環境別最適化
  - dev環境: 1AZ、最小リソース（コスト優先）
  - stg環境: 2AZ、中程度リソース
  - prod環境: 3AZ対応、高可用性

- 📝 .gitignore更新
  - Terraform State除外
  - 機密情報除外
  - 一時ファイル除外

### 修正
- N/A（初回リリース）

### 削除
- N/A（初回リリース）

### セキュリティ
- 🔒 すべての認証情報をSecrets Managerで管理
- 🔒 Private Subnetでアプリケーション・DBを保護
- 🔒 WAFによるL7保護
- 🔒 GuardDutyによる脅威検知

---

## [0.9.0] - 2025-10-15 (ベータ版)

### 追加
- 基本的なTerraform構成
- ECS Fargate + Aurora MySQL構成
- 手動デプロイスクリプト

### 既知の問題
- ドキュメント不足
- CI/CD未実装
- セキュリティ機能が限定的

---

## バージョニングについて

このプロジェクトは [Semantic Versioning](https://semver.org/lang/ja/) に従います。

- **MAJOR**: 互換性のない変更
- **MINOR**: 後方互換性のある機能追加
- **PATCH**: 後方互換性のあるバグ修正

---

## リンク

- [Unreleased]: 最新のmainブランチ
- [1.0.0]: https://github.com/your-username/srep1/releases/tag/v1.0.0
- [0.9.0]: ベータ版（非公開）

