# WAF モジュール

このモジュールは、AWS WAF v2を使用してWebアプリケーションのセキュリティを強化するためのリソースを作成します。

## 機能

- **WAF Web ACL**: セキュリティルールを定義するWeb ACL
- **AWS Managed Rules**: 一般的な攻撃パターンを検出するAWS管理ルール
- **レート制限**: IPアドレスベースのレート制限
- **ログ機能**: WAFログのS3保存とCloudWatchメトリクス
- **セキュリティ設定**: S3バケットの暗号化とパブリックアクセスブロック

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
  log_retention_days = 30
  
  enable_rate_limit = true
  rate_limit_requests_per_5_minutes = 2000
  
  redacted_headers = ["authorization", "cookie", "x-forwarded-for"]
  
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
| tags | リソースに付与するタグ | map(string) | {} | いいえ |
| enable_logging | WAFログの有効化 | bool | true | いいえ |
| log_retention_days | WAFログの保持日数 | number | 30 | いいえ |
| redacted_headers | ログから除外するヘッダー | list(string) | ["authorization", "cookie", "x-forwarded-for"] | いいえ |
| enable_rate_limit | レート制限の有効化 | bool | true | いいえ |
| rate_limit_requests_per_5_minutes | 5分間あたりのリクエスト制限数 | number | 2000 | いいえ |

## 出力値

| 出力名 | 説明 |
|--------|------|
| web_acl_id | WAF Web ACLのID |
| web_acl_arn | WAF Web ACLのARN |
| web_acl_name | WAF Web ACLの名前 |
| waf_logs_bucket_name | WAFログ用S3バケット名 |
| waf_logs_bucket_arn | WAFログ用S3バケットのARN |
| firehose_delivery_stream_arn | Kinesis Firehose配信ストリームのARN |

## 作成されるリソース

- `aws_wafv2_web_acl`: WAF Web ACL
- `aws_kinesis_firehose_delivery_stream`: WAFログ用のKinesis Firehose
- `aws_s3_bucket`: WAFログ保存用S3バケット
- `aws_s3_bucket_lifecycle_configuration`: S3バケットのライフサイクル設定
- `aws_s3_bucket_versioning`: S3バケットのバージョニング設定
- `aws_s3_bucket_server_side_encryption_configuration`: S3バケットの暗号化設定
- `aws_s3_bucket_public_access_block`: S3バケットのパブリックアクセスブロック設定
- `aws_iam_role`: Kinesis Firehose用のIAMロール
- `aws_iam_role_policy`: Kinesis Firehose用のIAMポリシー
- `random_string`: S3バケット名の重複回避用ランダム文字列

## セキュリティ考慮事項

- WAFログには機密情報（認証ヘッダー、Cookie等）が含まれるため、適切にマスキングされています
- S3バケットは暗号化され、パブリックアクセスがブロックされています
- ログは設定された期間後に自動的に削除されます

## ALBへのアタッチ方法

WAF Web ACLをALBにアタッチするには、ALBモジュールで以下のように設定します：

```hcl
module "alb" {
  # ... 他の設定 ...
  
  web_acl_arn = module.waf.web_acl_arn
}
```

## 注意事項

- WAF Web ACLはリージョナルスコープで作成されます
- レート制限はIPアドレスベースで動作します
- ログ機能を無効にした場合、S3バケットとKinesis Firehoseは作成されません 