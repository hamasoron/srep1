# AWS セキュリティ統合モジュール（モジュール分割版）

## 🎯 改善点

従来の`eventbridge-sns`モジュールを責任分離の原則に基づいて以下の3つのモジュールに分割しました：

### ✅ モジュール分割のメリット

| 分割前 | 分割後 |
|--------|--------|
| **eventbridge-sns** (巨大) | **eventbridge** (軽量) |
| - EventBridge | - EventBridgeルール・ターゲット |
| - SNS + KMS | **sns** (軽量) |
| - Lambda | - SNSトピック + KMS暗号化 |
| - 複雑な依存関係 | **slack-notification** (軽量) |
| | - Lambda関数 + Slack通知 |

## 🏗️ 新しいアーキテクチャ

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  CloudTrail │    │ GuardDuty   │    │EventBridge  │
│   モジュール  │───▶│  モジュール  │───▶│  モジュール  │
│             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────┬───────┘
                                              │
                   ┌─────────────┐           │
                   │    SNS      │◀──────────┤
                   │  モジュール  │           │
                   └─────────────┘           │
                                              │
                   ┌─────────────┐           │
                   │   Slack     │◀──────────┘
                   │通知モジュール│
                   └─────────────┘
```

## 📦 モジュール構成

### 1. EventBridge モジュール (`modules/eventbridge/`)
**責任**: イベントルーティング
- EventBridgeルールの作成・管理
- ターゲット設定
- イベントパターン定義
- スケジュール式対応

### 2. SNS モジュール (`modules/sns/`)
**責任**: 通知トピック管理
- SNSトピックの作成・管理
- KMS暗号化
- ポリシー設定
- フィードバック設定

### 3. Slack通知 モジュール (`modules/slack-notification/`)
**責任**: Slack通知機能
- Lambda関数
- IAM権限
- CloudWatch Logs
- Slack Webhook統合

### 4. CloudTrail モジュール (`modules/cloudtrail/`)
**責任**: API監査ログ
- 全リージョン対応
- 管理イベント専用
- S3 + CloudWatch Logs

### 5. GuardDuty モジュール (`modules/guardduty/`)
**責任**: 脅威検出
- 包括的保護機能
- リアルタイム監視
- 検出結果の発行

## 🚀 使用方法

### 基本構成（全モジュール使用）

```hcl
# SNSトピック作成
module "sns" {
  source = "./modules/sns"

  system_name      = "my-system"
  environment_name = "production"
  
  create_sns_topic  = true
  display_name      = "Security Alerts"
  enable_encryption = true
  create_kms_key    = true
}

# Slack通知Lambda作成
module "slack_notification" {
  source = "./modules/slack-notification"

  system_name       = "my-system"
  environment_name  = "production"
  
  slack_webhook_url = var.slack_webhook_url
  slack_channel     = "#security"
}

# EventBridgeルール作成
module "eventbridge" {
  source = "./modules/eventbridge"

  system_name      = "my-system"
  environment_name = "production"
  
  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })
  
  targets = [
    {
      target_id = "SNS"
      arn       = module.sns.sns_topic_arn
    },
    {
      target_id = "Lambda"
      arn       = module.slack_notification.lambda_function_arn
    }
  ]
}
```

### 個別モジュール使用例

#### EventBridgeのみ使用
```hcl
module "eventbridge_only" {
  source = "./modules/eventbridge"

  system_name      = "my-system"
  environment_name = "development"
  
  # CloudWatchアラーム用
  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
  })
  
  targets = [
    {
      target_id = "ExistingSNS"
      arn       = "arn:aws:sns:us-east-1:123456789012:existing-topic"
    }
  ]
}
```

#### SNSのみ使用
```hcl
module "sns_only" {
  source = "./modules/sns"

  system_name      = "notification-system"
  environment_name = "staging"
  
  topic_name        = "custom-alerts"
  display_name      = "Custom Alert Topic"
  enable_encryption = false  # 暗号化無効
  create_kms_key    = false
}
```

#### Slack通知のみ使用
```hcl
module "slack_only" {
  source = "./modules/slack-notification"

  system_name      = "chat-system"
  environment_name = "production"
  
  function_name      = "custom-slack-notifier"
  slack_webhook_url  = var.webhook_url
  slack_channel      = "#devops"
  lambda_timeout     = 120
  lambda_memory_size = 256
}
```

## 🔄 マイグレーション（既存モジュールからの移行）

### 移行手順

1. **既存リソースの確認**
```bash
terraform state list | grep eventbridge-sns
```

2. **新しいモジュール構成でplan実行**
```bash
terraform plan -target=module.sns
terraform plan -target=module.slack_notification  
terraform plan -target=module.eventbridge
```

3. **段階的デプロイ**
```bash
# SNS作成
terraform apply -target=module.sns

# Lambda作成  
terraform apply -target=module.slack_notification

# EventBridge作成
terraform apply -target=module.eventbridge

# 旧モジュール削除
terraform destroy -target=module.eventbridge_sns
```

## 📊 モジュール比較表

| 項目 | 統合モジュール | 分割モジュール |
|------|-------------|-------------|
| **再利用性** | ❌ 低い | ✅ 高い |
| **保守性** | ❌ 困難 | ✅ 容易 |
| **責任分離** | ❌ 曖昧 | ✅ 明確 |
| **柔軟性** | ❌ 制限あり | ✅ 高い |
| **テスト性** | ❌ 複雑 | ✅ 単純 |
| **初期設定** | ✅ 簡単 | ⚠️ やや複雑 |

## 🎯 使い分けの指針

### 統合モジュールが適している場合
- プロトタイプ開発
- 小規模プロジェクト
- 設定の簡素化を重視

### 分割モジュールが適している場合
- 本格運用
- 大規模プロジェクト
- 再利用性を重視
- チーム開発
- 段階的デプロイ

## 💡 ベストプラクティス

### 1. モジュール間の依存関係管理
```hcl
# 明示的な依存関係
module "eventbridge" {
  # ...
  depends_on = [module.sns, module.slack_notification]
}
```

### 2. 共通タグの活用
```hcl
locals {
  common_tags = {
    Environment = var.environment_name
    Project     = var.system_name
    ManagedBy   = "Terraform"
  }
}

module "sns" {
  # ...
  tags = local.common_tags
}
```

### 3. 条件付きリソース作成
```hcl
module "slack_notification" {
  count = var.enable_slack_notifications ? 1 : 0
  # ...
}
```

### 4. 出力値の活用
```hcl
# 他のモジュールやリソースで使用
resource "aws_lambda_permission" "eventbridge" {
  function_name = module.slack_notification[0].lambda_function_name
  source_arn    = module.eventbridge.eventbridge_rule_arn
}
```

## 📈 料金最適化

### モジュール別コスト要因

| モジュール | 主要コスト | 最適化ポイント |
|-----------|-----------|-------------|
| **EventBridge** | イベント処理数 | フィルタリング強化 |
| **SNS** | メッセージ送信数 | 重要度フィルタ |
| **Slack通知** | Lambda実行時間 | タイムアウト調整 |
| **CloudTrail** | ログボリューム | 管理イベントのみ |
| **GuardDuty** | 保護機能数 | 必要機能の選択 |

## 🔧 トラブルシューティング

### よくある問題と解決策

#### 1. モジュール間の循環依存
```hcl
# ❌ 悪い例
module "a" {
  some_value = module.b.output_value
}
module "b" {
  some_value = module.a.output_value
}

# ✅ 良い例  
module "a" {
  # 独立した設定
}
module "b" {
  some_value = module.a.output_value
}
```

#### 2. 権限エラー
```hcl
# EventBridgeからLambda呼び出し権限
resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.slack_notification.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = module.eventbridge.eventbridge_rule_arn
}
```

#### 3. 出力値の参照エラー
```hcl
# countを使用したモジュールの出力値参照
output "lambda_arn" {
  value = length(module.slack_notification) > 0 ? module.slack_notification[0].lambda_function_arn : null
}
```

## 📚 参考資料

- [Terraform Module Best Practices](https://developer.hashicorp.com/terraform/tutorials/modules)
- [AWS EventBridge 料金](https://aws.amazon.com/eventbridge/pricing/)
- [AWS SNS 料金](https://aws.amazon.com/sns/pricing/)
- [AWS Lambda 料金](https://aws.amazon.com/lambda/pricing/)

---

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。 