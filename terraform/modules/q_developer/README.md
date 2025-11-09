# AWS Chatbot モジュール

このモジュールは、AWS ChatbotとSlackの統合を設定し、SNS通知をSlackチャンネルに配信します。Amazon Q Developerとの統合により、Slack内でAIアシスタント機能も利用できます。

## 機能

- AWS ChatbotとSlackワークスペースの統合
- SNSトピックからの通知をSlackチャンネルに配信
- Amazon Q Developer機能の有効化
- 外部IAMロール（iam_roleモジュール）を使用

## 前提条件

1. **Slackワークスペース**: 管理者権限を持つSlackワークスペース
2. **Slack App**: AWS Chatbot用のSlackアプリの設定
3. **チャンネル情報**: Slack チャンネルIDとチームID

## Slack設定の準備

### 1. Slack App の作成
1. [Slack API](https://api.slack.com/apps) にアクセス
2. "Create New App" をクリック
3. "From scratch" を選択
4. アプリ名とワークスペースを設定

### 2. 権限の設定
以下のBot Token Scopesを追加：
- `chat:write`
- `im:read`
- `im:write`

### 3. チャンネル情報の取得
- **チャンネルID**: Slackチャンネルで右クリック → "View channel details" → 下部にチャンネルIDが表示
- **チームID**: SlackワークスペースのURLから取得 (`https://app.slack.com/client/T0123456789` の `T0123456789` 部分)

## 使用方法

```hcl
module "chatbot" {
  source = "../modules/chatbot"

  # 基本設定
  system_name      = var.system_name
  environment_name = var.environment_name

  # IAM設定
  iam_role_arn = module.iam_role.iam_role_chatbot_arn

  # SNS設定
  sns_topic_arn = module.sns.sns_guardduty_topic_arn

  # Slack設定
  slack_channel_id = "C1234567890"  # 実際のチャンネルIDに置き換え
  slack_team_id    = "T0987654321"  # 実際のチームIDに置き換え

  # ChatBot設定（オプション）
  logging_level               = "ERROR"
  user_authorization_required = true
}
```

## 入力変数

| 変数名 | 説明 | 型 | 必須 | デフォルト値 |
|--------|------|----|----|-------------|
| `system_name` | システム名 | string | Yes | - |
| `environment_name` | 環境名 (prod/stg/dev) | string | Yes | - |
| `iam_role_arn` | ChatBot用のIAMロールARN | string | Yes | - |
| `sns_topic_arn` | 購読するSNSトピックのARN | string | Yes | - |
| `slack_channel_id` | SlackチャンネルID | string | Yes | - |
| `slack_team_id` | SlackチームID | string | Yes | - |
| `logging_level` | ログレベル | string | No | "ERROR" |
| `user_authorization_required` | Amazon Q Developer機能でのユーザー認証要求 | bool | No | true |

## 出力値

| 出力名 | 説明 |
|--------|------|
| `chatbot_configuration_arn` | ChatBot Slack設定のARN |
| `chatbot_iam_role_arn` | ChatBot IAMロールのARN |
| `slack_channel_id` | 設定されたSlackチャンネルID |

## Amazon Q Developer の使用方法

Slack内で以下のようにAmazon Q Developerと対話できます：

```
@Amazon Q GuardDutyアラートの対処方法を教えて
@Amazon Q S3バケットのセキュリティを強化する方法は？
@Amazon Q aws s3 ls
```

## 統合例

既存のGuardDuty → EventBridge → SNS の流れにChatbotを追加：

```hcl
# IAM Roleモジュール
module "iam_role" {
  source = "../modules/iam_role"
  # ... 設定
}

# GuardDutyモジュール
module "guardduty" {
  source = "../modules/guardduty_cfn"
  # ... 設定
}

# EventBridgeモジュール
module "eventbridge" {
  source = "../modules/eventbridge"
  sns_guardduty_topic_arn = module.sns.sns_guardduty_topic_arn
  # ... その他設定
}

# SNSモジュール
module "sns" {
  source = "../modules/sns"
  # ... 設定
}

# Chatbotモジュール（新規追加）
module "chatbot" {
  source = "../modules/chatbot"
  
  system_name      = var.system_name
  environment_name = var.environment_name
  iam_role_arn     = module.iam_role.iam_role_chatbot_arn
  sns_topic_arn    = module.sns.sns_guardduty_topic_arn
  slack_channel_id = var.slack_channel_id
  slack_team_id    = var.slack_team_id
  depends_on       = [module.iam_role, module.sns]
}
```

## 注意事項

1. **IAMロール**: このモジュールは外部で定義されたIAMロールを使用します（iam_roleモジュール経由）
2. **権限**: Slackアプリには適切なスコープが設定されている必要があります
3. **セキュリティ**: IAM権限はiam_roleモジュールで一元管理されます
4. **認証**: Amazon Q Developer機能を使用する場合、ユーザーのAWS認証が必要です

## トラブルシューティング

### よくある問題

1. **チャンネルIDが無効**: SlackチャンネルIDは 'C' で始まる文字列である必要があります
2. **権限エラー**: ChatbotがSNSトピックにアクセスできない場合はIAM権限を確認してください
3. **Slack認証エラー**: Slackアプリがワークスペースにインストールされているか確認してください 