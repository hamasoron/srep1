# AWS セキュリティ統合モジュール

CloudTrail、GuardDuty、EventBridge/SNSを組み合わせた包括的なAWSセキュリティ監視システムです。

## 🎯 目的

1. **CloudTrail**: 全リージョンのAPIコールを記録（管理イベントのみ）
2. **GuardDuty**: CloudTrailログの中で不正なものをコンソール上に表示
3. **EventBridge/SNS**: GuardDutyで検知した脅威をSlackに自動通知

## 🏗️ アーキテクチャ

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  全リージョン │    │ CloudTrail  │    │ GuardDuty   │    │ EventBridge │
│  API コール  │───▶│    ログ     │───▶│   脅威検知   │───▶│ + Lambda    │
│             │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                           │                                      │
                           ▼                                      ▼
                   ┌─────────────┐                        ┌─────────────┐
                   │ S3 + CloudWatch │                        │   Slack     │
                   │    ログ保存    │                        │    通知     │
                   └─────────────┘                        └─────────────┘
```

## 📦 モジュール構成

### 1. CloudTrail モジュール (`modules/cloudtrail/`)
- **目的**: 全リージョンのAWS APIコールを記録
- **特徴**:
  - マルチリージョン対応
  - 管理イベントのみ記録（データ・インサイトイベントは除外）
  - S3とCloudWatch Logsにログ保存
  - ログファイル整合性検証

### 2. GuardDuty モジュール (`modules/guardduty/`)
- **目的**: CloudTrailログから不正活動を検出
- **特徴**:
  - 包括的な脅威検出（マルウェア、Kubernetes、ランタイム監視等）
  - CloudWatch Events統合
  - カスタマイズ可能な検出頻度

### 3. EventBridge/SNS モジュール (`modules/eventbridge-sns/`)
- **目的**: GuardDuty検出結果をSlackに自動通知
- **特徴**:
  - リアルタイム通知
  - 重要度レベルによるフィルタリング
  - 美しいSlackメッセージフォーマット
  - SNS暗号化対応

## 🚀 使用方法

### 基本的な設定

```hcl
module "security_integration" {
  source = "./terraform/environments/"

  system_name      = "my-security-system"
  environment_name = "production"
  
  # Slack通知を有効にする場合
  slack_webhook_url = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
}
```

### カスタマイズ例

```hcl
# 1. CloudTrailモジュール個別使用
module "cloudtrail" {
  source = "./modules/cloudtrail"

  system_name      = "my-system"
  environment_name = "production"

  # 管理イベントのみ記録
  event_selector_include_management_events = true
  enable_data_events                       = false
  enable_insight_events                    = false

  # 全リージョン対応
  is_multi_region_trail         = true
  include_global_service_events = true
}

# 2. GuardDutyモジュール個別使用
module "guardduty" {
  source = "./modules/guardduty"

  system_name      = "my-system"
  environment_name = "production"

  # 保護機能の設定
  enable_malware_protection    = true
  enable_kubernetes_protection = true
  enable_runtime_monitoring    = true
  enable_lambda_protection     = true
  enable_rds_protection        = true
  enable_s3_protection         = true

  finding_publishing_frequency = "FIFTEEN_MINUTES"
}

# 3. EventBridge/SNSモジュール個別使用
module "eventbridge_sns" {
  source = "./modules/eventbridge-sns"

  system_name      = "my-system"
  environment_name = "production"

  # 中〜高重要度のみ通知
  guardduty_severity_levels = ["MEDIUM", "HIGH"]

  # Slack設定
  slack_webhook_url = var.slack_webhook_url
  slack_channel     = "#security-alerts"
}
```

## 📋 前提条件

### AWS権限
- CloudTrail管理権限
- GuardDuty管理権限
- EventBridge/CloudWatch Events権限
- SNS権限
- Lambda権限
- S3バケット作成・管理権限
- IAM権限

### Slack設定（任意）
1. Slackワークスペースでアプリを作成
2. Incoming Webhooksを有効化
3. Webhook URLを取得

## 🔧 設定手順

### 1. Slackアプリの作成（任意）

```bash
# 1. https://api.slack.com/apps にアクセス
# 2. "Create New App" をクリック
# 3. "From scratch" を選択
# 4. アプリ名とワークスペースを選択
# 5. "Incoming Webhooks" を有効化
# 6. "Add New Webhook to Workspace" をクリック
# 7. 通知先チャンネルを選択
# 8. Webhook URLをコピー
```

### 2. Terraformデプロイ

```bash
# リポジトリのクローン
git clone <repository-url>
cd terraform/environments/

# 変数の設定
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvarsを編集してslack_webhook_urlを設定

# デプロイ実行
terraform init
terraform plan
terraform apply
```

### 3. 動作確認

```bash
# GuardDutyのテスト検出を発生させる
aws guardduty create-sample-findings \
  --detector-id $(terraform output -raw guardduty_detector_id) \
  --finding-types "Recon:EC2/PortProbeUnprotectedPort"

# Slackに通知が届くことを確認
```

## 📊 監視・運用

### ログの確認場所

| サービス | ログの場所 | 確認方法 |
|---------|-----------|----------|
| CloudTrail | S3バケット + CloudWatch Logs | AWSコンソール |
| GuardDuty | AWSコンソール | GuardDuty Findings |
| Lambda | CloudWatch Logs | `/aws/lambda/function-name` |

### アラートの重要度レベル

| レベル | 範囲 | 色 | 対応 |
|--------|------|----|----- |
| 🔴 HIGH | 7.0-10.0 | 赤 | 即座に対応 |
| 🟡 MEDIUM | 4.0-6.9 | 黄 | 24時間以内に対応 |
| 🔵 LOW | 0.1-3.9 | 青 | 確認・記録 |

### 運用のベストプラクティス

1. **定期レビュー**: 月次でGuardDuty検出結果をレビュー
2. **フィルタリング**: 重要度に基づく通知のフィルタリング
3. **インシデント対応**: 検出結果に基づく対応手順の策定
4. **コスト監視**: GuardDutyとCloudTrailの利用料金を監視

## 💰 料金について

### CloudTrail
- 管理イベント: 最初の250万イベントまで無料
- S3ストレージ: 標準料金

### GuardDuty
- 基本料金: 地域により異なる
- 追加機能（マルウェア保護等）: 別途課金

### その他のサービス
- EventBridge: イベント処理数に応じて課金
- Lambda: 実行時間とメモリ使用量
- SNS: メッセージ送信数
- S3: ストレージ使用量

## 🔒 セキュリティ考慮事項

1. **暗号化**: S3バケットとSNSトピックの暗号化
2. **アクセス制御**: 最小権限の原則
3. **ログ保護**: CloudTrailログの改ざん防止
4. **Slack Webhook**: Webhook URLの安全な管理

## 🐛 トラブルシューティング

### よくある問題

#### Slack通知が届かない
```bash
# Lambda関数のログを確認
aws logs describe-log-streams \
  --log-group-name "/aws/lambda/your-function-name"

# EventBridgeルールの確認
aws events describe-rule --name "your-rule-name"
```

#### GuardDutyが検出しない
- CloudTrailが正常に動作しているか確認
- GuardDutyの保護機能が有効になっているか確認
- 検出には時間がかかる場合があります（最大15分）

#### CloudTrailログが記録されない
- S3バケットポリシーの確認
- IAMロールの権限確認
- リージョン設定の確認

## 📚 参考資料

- [AWS CloudTrail ユーザーガイド](https://docs.aws.amazon.com/cloudtrail/)
- [AWS GuardDuty ユーザーガイド](https://docs.aws.amazon.com/guardduty/)
- [Amazon EventBridge ユーザーガイド](https://docs.aws.amazon.com/eventbridge/)
- [Slack API ドキュメント](https://api.slack.com/)

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。 