# 変数の定義
## 全般
variable "system_name" {
  description = "システム名"
  type        = string
}

variable "environment_name" {
  description = "環境名"
  type        = string
}

## S3
variable "s3_cloudtrail_logs_bucket_name" {
  description = "CloudTrailログ用のS3バケット名（S3モジュールのoutputs.tfの受け皿として定義）"
  type        = string
}

## CloudTrail
variable "enable_management_logging" {
  description = "管理イベント証跡のログ記録を有効にするかどうか（セキュリティ・コンプライアンス上重要）"
  type        = bool
}

variable "enable_data_logging" {
  description = "データイベント証跡のログ記録を有効にするかどうか（大量ログ発生のため注意）"
  type        = bool
}

variable "enable_insight_logging" {
  description = "インサイトイベント証跡のログ記録を有効にするかどうか（追加コスト発生）"
  type        = bool
}

variable "include_global_service_events" {
  description = "グローバルサービスイベントを含めるかどうか"
  type        = bool
}

variable "is_multi_region_trail" {
  description = "マルチリージョントレイルにするかどうか"
  type        = bool
}

variable "enable_log_file_validation" {
  description = "ログファイル検証を有効にするかどうか"
  type        = bool
}

variable "event_selector_include_management_events" {
  description = "管理イベントを含めるかどうか"
  type        = bool
}

variable "event_selector_read_write_type" {
  description = "読み書きのイベントを記録するかどうか"
  type        = string
}

variable "exclude_management_event_sources" {
  description = "管理イベントに含めないイベントソース"
  type        = list(string)
}