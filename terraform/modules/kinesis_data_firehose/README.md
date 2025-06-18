# Kinesis Data Firehose モジュール

このモジュールは、AWS Kinesis Data Firehoseを使用してデータストリーミングとログ配信を行うためのリソースを作成します。

## 機能

- **複数配信ストリーム**: 複数のKinesis Data Firehose配信ストリームを同時に管理
- **S3出力**: Extended S3設定によるS3バケットへのデータ配信
- **圧縮設定**: データ転送量の削減
- **CloudWatch Logging**: Firehose自体のログ出力
- **S3バックアップ**: 失敗時のデータバックアップ

## 使用方法

```hcl
module "kinesis_firehose" {
  source = "../../modules/kinesis_firehose"

  system_name      = "srep1"
  environment_name = "dev"
  
  delivery_streams = {
    waf_logs = {
      name        = "waf-logs"
      destination = "extended_s3"
      role_arn    = module.iam_role.iam_role_waf_firehose_role_arn
      bucket_arn  = "arn:aws:s3:::srep1-dev-waf-logs"
      prefix      = "waf-logs/"
      
      compression_format = "GZIP"
      
      enable_cloudwatch_logging = true
      cloudwatch_log_group_name = "/aws/firehose/waf-logs"
      cloudwatch_log_stream_name = "delivery-stream"
      
      tags = {
        Purpose = "WAF Logging"
      }
    }
  }
  
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
| delivery_streams | 配信ストリーム設定のマップ | map(object) | - | はい |
| tags | リソースに付与するタグ | map(string) | {} | いいえ |

### delivery_streams オブジェクト構造

| フィールド名 | 説明 | 型 | デフォルト値 | 必須 |
|-------------|------|----|-------------|------|
| name | 配信ストリーム名 | string | - | はい |
| destination | 配信先タイプ | string | - | はい |
| role_arn | IAMロールのARN | string | - | はい |
| bucket_arn | S3バケットのARN | string | - | はい |
| prefix | S3プレフィックス | string | - | はい |
| compression_format | 圧縮形式 | string | "UNCOMPRESSED" | いいえ |
| enable_s3_backup | S3バックアップ有効化 | bool | false | いいえ |
| enable_cloudwatch_logging | CloudWatch Logging有効化 | bool | false | いいえ |
| cloudwatch_log_group_name | CloudWatch Log Group名 | string | - | いいえ |
| cloudwatch_log_stream_name | CloudWatch Log Stream名 | string | - | いいえ |
| tags | ストリーム固有のタグ | map(string) | {} | いいえ |

## 出力値

| 出力名 | 説明 |
|--------|------|
| delivery_stream_arns | 配信ストリームARNのマップ |
| delivery_stream_names | 配信ストリーム名のマップ |
| delivery_stream_ids | 配信ストリームIDのマップ |

## 作成されるリソース

- `aws_kinesis_firehose_delivery_stream`: Kinesis Firehose配信ストリーム

## 対応している配信先

- `extended_s3`: Extended S3設定（推奨）
- `s3`: 標準S3設定
- `elasticsearch`: Elasticsearch
- `splunk`: Splunk
- `http_endpoint`: HTTPエンドポイント
- `redshift`: Amazon Redshift

## 圧縮形式

- `UNCOMPRESSED`: 圧縮なし
- `GZIP`: GZIP圧縮
- `HADOOP_SNAPPY`: Snappy圧縮
- `HADOOP_BZIP2`: Bzip2圧縮

## セキュリティ考慮事項

- IAMロールには必要最小限の権限のみを付与
- S3バケットは暗号化され、適切なアクセス制御が設定されていることを確認
- CloudWatch Loggingを有効にして、配信ストリームの監視を実施

## パフォーマンス最適化

- 大量のデータを処理する場合は、圧縮を有効にする
- 重要なデータの場合は、S3バックアップを有効にする 