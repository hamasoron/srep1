# EventBridge Module

このモジュールは、Amazon GuardDutyの検出結果をキャプチャし、SNSやLambdaに通知するEventBridgeルールを作成します。

## 機能

- GuardDuty検出結果をイベントソースとするEventBridgeルール
- SNSトピックへの通知機能
- Lambdaファンクションの実行機能（オプション）
- 重要度による検出結果のフィルタリング
- メッセージの変換とカスタマイズ

## 使用方法

### 基本的な使用例

```hcl
module "eventbridge" {
  source = "../modules/eventbridge"
  
  system_name      = "my-system"
  environment_name = "prod"
  sns_topic_arn    = module.sns.topic_arn
  
  tags = {
    Environment = "prod"
    Team        = "security"
  }
}
```

### 詳細設定での使用例

```hcl
module "eventbridge" {
  source = "../modules/eventbridge"
  
  system_name      = "my-system"
  environment_name = "prod"
  
  # EventBridge設定
  create_eventbridge_rule = true
  event_rule_state       = "ENABLED"
  severity_filter        = [7.0, 8.5, 10.0]  # HIGH重要度のみ
  
  # ターゲット設定
  sns_topic_arn       = module.sns.topic_arn
  lambda_function_arn = module.lambda.function_arn
  lambda_function_name = module.lambda.function_name
  
  tags = {
    Environment = "prod"
    Team        = "security"
    Purpose     = "guardduty-notification"
  }
}
```

## 入力変数

| 変数名                    | 型             | デフォルト値 | 説明                                  |
|---------------------------|----------------|--------------|-----------------------------------------|
| system_name               | string        | -            | システム名                             |
| environment_name          | string        | -            | 環境名（prod/stg/dev）                |
| tags                      | map(string)   | {}           | リソースに適用するタグ                |
| create_eventbridge_rule   | bool          | true         | EventBridgeルールを作成するかどうか   |
| event_rule_state          | string        | "ENABLED"    | EventBridgeルールの状態               |
| severity_filter           | list(number)  | [1.0, 4.0, 7.0, 8.5, 10.0] | 重要度フィルター |
| sns_topic_arn             | string        | ""           | 通知先SNSトピックのARN                |
| lambda_function_arn       | string        | ""           | 実行するLambda関数のARN（オプション） |
| lambda_function_name      | string        | ""           | 実行するLambda関数名（オプション）    |

## 出力値

| 出力名                        | 説明                          |
|-------------------------------|-------------------------------|
| eventbridge_rule_name         | EventBridgeルールの名前       |
| eventbridge_rule_arn          | EventBridgeルールのARN        |
| eventbridge_rule_id           | EventBridgeルールのID         |
| eventbridge_rule_state        | EventBridgeルールの状態       |
| eventbridge_rule_description  | EventBridgeルールの説明       |
| sns_target_id                 | SNSターゲットのID             |
| lambda_target_id              | LambdaターゲットのID          |
| configured_sns_topic_arn      | 設定されたSNSトピックのARN    |
| configured_lambda_function_arn| 設定されたLambda関数のARN     |

## GuardDuty重要度について

GuardDutyの重要度は以下の範囲で設定されます：

- **LOW**: 1.0 - 3.9
- **MEDIUM**: 4.0 - 6.9  
- **HIGH**: 7.0 - 10.0

## メッセージ変換

SNSに送信されるメッセージは以下の形式で変換されます：

```json
{
  "alert_type": "GuardDuty Finding",
  "severity": "7.0",
  "finding_type": "UnauthorizedAPICall",
  "region": "ap-northeast-1",
  "account_id": "123456789012",
  "title": "Cryptocurrency mining activity detected",
  "description": "EC2 instance is communicating with cryptocurrency mining pool.",
  "timestamp": "2023-01-01T00:00:00Z",
  "message": "GuardDuty検出: Cryptocurrency mining activity detected - 重要度: 7.0"
}
```

## 依存関係

このモジュールは以下のリソースと連携します：

- **GuardDuty**: `guardduty_cfn` モジュール
- **SNS**: `sns` モジュール  
- **Lambda**: `lambda` モジュール（オプション）

## 注意事項

1. GuardDutyが事前に有効化されている必要があります
2. SNSトピックには適切なポリシーが設定されている必要があります
3. Lambda関数を使用する場合は、EventBridgeからの実行権限が必要です
4. マルチリージョン環境では、各リージョンでEventBridgeルールを作成する必要があります 