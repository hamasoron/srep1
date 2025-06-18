# WAF モジュール

このモジュールは、AWS WAF v2を使用してWebアプリケーションのセキュリティを強化するためのリソースを作成します。

## 機能

- **WAF Web ACL**: セキュリティルールを定義するWeb ACL
- **AWS Managed Rules**: 一般的な攻撃パターンを検出するAWS管理ルール
- **レート制限**: IPアドレスベースのレート制限
- **ログ機能**: WAFログのKinesis Firehose経由でのS3保存とCloudWatchメトリクス
- **セキュリティ設定**: 機密情報のマスキング

## 含まれるAWS Managed Rules

1. **AWSManagedRulesCommonRuleSet**: 一般的なWeb攻撃の検出
2. **AWSManagedRulesKnownBadInputsRuleSet**: 既知の悪意のある入力の検出
3. **AWSManagedRulesSQLiRuleSet**: SQLインジェクション攻撃の検出
4. **AWSManagedRulesLinuxRuleSet**: Linuxシステムへの攻撃の検出
5. **AWSManagedRulesAnonymousIpList**: 匿名IPアドレスからのアクセス検出

## 使用方法

```hcl
module "waf" {
  source = "../../modules/waf"

  system_name      = "srep1"
  environment_name = "dev"
  
  enable_logging   = true
  redacted_headers = ["authorization", "cookie", "x-forwarded-for"]
  
  enable_rate_limit = true
  rate_limit_requests_per_5_minutes = 2000
  
  firehose_delivery_stream_arn = module.kinesis_firehose.delivery_stream_arns["waf_logs"]
  
  tags = {
    Environment = "dev"
    Project     = "srep1"
  }
}
```

## 入力変数

| 変数名 | 説明 | 型 | デフォルト値 | 必須 |
|--------|------|----|-------------|------|
| system_name | システム名 | string | - | はい |
| environment_name | 環境名 | string | - | はい |
| scope | WAFのスコープ | string | - | はい |
| override_action | オーバーライドアクション | string | - | はい |
| enable_logging | WAFログの有効化 | bool | - | はい |
| redacted_headers | ログから除外するヘッダー | list(string) | ["authorization", "cookie", "x-forwarded-for"] | いいえ |
| enable_rate_limit | レート制限の有効化 | bool | true | いいえ |
| rate_limit_requests_per_5_minutes | 5分間あたりのリクエスト制限数 | number | 1000 | いいえ |
| firehose_role_arn | Kinesis Firehose用IAMロールのARN | string | null | いいえ |
| firehose_delivery_stream_arn | Kinesis Firehose配信ストリームのARN | string | null | いいえ |
| tags | リソースに付与するタグ | map(string) | {} | いいえ |

## 出力値

| 出力名 | 説明 |
|--------|------|
| web_acl_id | WAF Web ACLのID |
| web_acl_arn | WAF Web ACLのARN |
| web_acl_name | WAF Web ACLの名前 |

## 作成されるリソース

- `aws_wafv2_web_acl`: WAF Web ACL
- `aws_wafv2_web_acl_logging_configuration`: WAFログ設定

## セキュリティ考慮事項

- WAFログには機密情報（認証ヘッダー、Cookie等）が含まれるため、適切にマスキングされています
- Kinesis Firehose経由でS3に保存されるログは暗号化されています
- ログは設定された期間後に自動的に削除されます

## ALBへのアタッチ方法

WAF Web ACLをALBにアタッチするには、ALBモジュールで以下のように設定します：

```hcl
module "alb" {
  # ... 他の設定 ...
  
  web_acl_arn = module.waf.web_acl_arn
}
```

## Kinesis Data Firehoseとの連携

WAFログは独立したKinesis Data Firehoseモジュールを介してS3に保存されます：

```hcl
module "kinesis_data_firehose" {
  source = "../../modules/kinesis_data_firehose"
  
  delivery_streams = {
    waf_logs = {
      name        = "waf-logs"
      destination = "extended_s3"
      role_arn    = module.iam_role.iam_role_waf_firehose_role_arn
      bucket_arn  = "arn:aws:s3:::srep1-dev-waf-logs"
      prefix      = "waf-logs/"
    }
  }
}
```

## 注意事項

- WAF Web ACLはリージョナルスコープで作成されます
- レート制限はIPアドレスベースで動作します
- ログ機能を無効にした場合、Kinesis Data Firehoseは作成されません
- Kinesis Data Firehoseは独立したモジュールで管理されます 