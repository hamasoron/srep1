# GuardDuty モジュール

AWS GuardDutyのセキュリティ監視機能を設定するTerraformモジュールです。

## 機能

- GuardDutyディテクターの作成と設定
- 各種保護機能の有効/無効設定
  - マルウェア保護
  - Kubernetes保護
  - ランタイム監視
  - Lambda保護
  - RDS保護
  - S3保護
- CloudWatch Eventsルールによる検出結果の処理
- CloudWatch Logsによるログ保存
- SNS通知の設定（任意）

## 使用方法

### 基本的な使用例

```hcl
module "guardduty" {
  source = "./modules/guardduty"

  system_name      = "my-system"
  environment_name = "production"

  # GuardDuty基本設定
  enable_guardduty               = true
  finding_publishing_frequency   = "SIX_HOURS"

  # 保護機能の設定
  enable_malware_protection      = true
  enable_kubernetes_protection   = true
  enable_runtime_monitoring      = true
  enable_lambda_protection       = true
  enable_rds_protection          = true
  enable_s3_protection           = true

  # CloudWatch設定
  cloudwatch_event_rule_enabled = true

  tags = {
    Project = "MyProject"
    Owner   = "SecurityTeam"
  }
}
```

### SNS通知を含む設定例

```hcl
module "guardduty" {
  source = "./modules/guardduty"

  system_name      = "my-system"
  environment_name = "production"

  enable_guardduty               = true
  finding_publishing_frequency   = "FIFTEEN_MINUTES"

  # 保護機能を有効化
  enable_malware_protection      = true
  enable_kubernetes_protection   = true
  enable_runtime_monitoring      = true
  enable_lambda_protection       = true
  enable_rds_protection          = true
  enable_s3_protection           = true

  # CloudWatch Eventsとアラート設定
  cloudwatch_event_rule_enabled = true
  sns_topic_arn                 = "arn:aws:sns:ap-northeast-1:123456789012:guardduty-alerts"

  tags = {
    Environment = "production"
    Service     = "security"
  }
}
```

### 最小限の設定例

```hcl
module "guardduty" {
  source = "./modules/guardduty"

  system_name      = "my-system"
  environment_name = "development"

  # 基本的なGuardDutyのみ有効
  enable_guardduty               = true
  enable_malware_protection      = false
  enable_kubernetes_protection   = false
  enable_runtime_monitoring      = false
  enable_lambda_protection       = false
  enable_rds_protection          = false
  enable_s3_protection           = false

  cloudwatch_event_rule_enabled = false
}
```

## 入力変数

| 名前 | 説明 | 型 | デフォルト | 必須 |
|------|------|----|------------|------|
| system_name | システム名 | string | - | はい |
| environment_name | 環境名 | string | - | はい |
| enable_guardduty | GuardDutyを有効にするかどうか | bool | true | いいえ |
| enable_malware_protection | マルウェア保護を有効にするかどうか | bool | true | いいえ |
| enable_kubernetes_protection | Kubernetes保護を有効にするかどうか | bool | true | いいえ |
| enable_runtime_monitoring | ランタイム監視を有効にするかどうか | bool | true | いいえ |
| enable_lambda_protection | Lambda保護を有効にするかどうか | bool | true | いいえ |
| enable_rds_protection | RDS保護を有効にするかどうか | bool | true | いいえ |
| enable_s3_protection | S3保護を有効にするかどうか | bool | true | いいえ |
| finding_publishing_frequency | 検出結果の公開頻度 | string | "SIX_HOURS" | いいえ |
| cloudwatch_event_rule_enabled | CloudWatch Events ルールを有効にするかどうか | bool | true | いいえ |
| sns_topic_arn | SNSトピックARN（任意） | string | "" | いいえ |
| tags | リソースタグ | map(string) | {} | いいえ |

## 出力値

| 名前 | 説明 |
|------|------|
| guardduty_detector_id | GuardDutyディテクターのID |
| guardduty_detector_arn | GuardDutyディテクターのARN |
| cloudwatch_event_rule_name | CloudWatch Events ルールの名前 |
| cloudwatch_log_group_name | CloudWatch Log Groupの名前 |

## 注意事項

- GuardDutyは有料サービスです。使用前に料金体系をご確認ください
- 一部の保護機能（マルウェア保護など）は追加料金が発生します
- `finding_publishing_frequency`は "FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS" のいずれかを指定してください
- SNS通知を使用する場合は、事前にSNSトピックを作成し、ARNを指定してください

## 必要なプロバイダー

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.24.0"
    }
  }
}
```

## ライセンス

このモジュールはMITライセンスの下で公開されています。 