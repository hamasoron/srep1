# リソースの定義
## データリソース（現在のAWSアカウントのIDを取得）
data "aws_caller_identity" "terra_caller_identity" {} 
data "aws_region" "terra_current" {} 

## 証跡の作成（3つの証跡を作成）
resource "aws_cloudtrail" "terra_cloudtrail_management" {
  count          = var.enable_management_logging ? 1 : 0  # 管理ログが有効な場合のみ作成  
  name           = "${var.system_name}-${var.environment_name}-cloudtrail-management"
  s3_bucket_name = var.s3_cloudtrail_logs_bucket_name
  s3_key_prefix  = "management"
  enable_logging = true  # 作成される場合は常に有効
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  enable_log_file_validation    = var.enable_log_file_validation
  # 管理イベントの設定
  event_selector {
    include_management_events       = var.event_selector_include_management_events
    read_write_type                 = var.event_selector_read_write_type
    exclude_management_event_sources = var.exclude_management_event_sources
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-cloudtrail-management"
  }
}

resource "aws_cloudtrail" "terra_cloudtrail_data" {
  count          = var.enable_data_logging ? 1 : 0  # データログが有効な場合のみ作成
  name           = "${var.system_name}-${var.environment_name}-cloudtrail-data"
  s3_bucket_name = var.s3_cloudtrail_logs_bucket_name
  s3_key_prefix  = "data"
  enable_logging = true  # 作成される場合は常に有効
  is_multi_region_trail         = var.is_multi_region_trail
  enable_log_file_validation    = var.enable_log_file_validation
  # データイベントの設定
  event_selector {
    include_management_events = false  # 管理イベントは含めない
    read_write_type           = "All"
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::${var.system_name}-${var.environment_name}-*"]
    }
    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda:${data.aws_region.terra_current.name}:${data.aws_caller_identity.terra_caller_identity.account_id}:function:${var.system_name}-${var.environment_name}-*"]
    }
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-cloudtrail-data"
  }
}

resource "aws_cloudtrail" "terra_cloudtrail_insight" {
  count          = var.enable_insight_logging ? 1 : 0  # インサイトログが有効な場合のみ作成
  name           = "${var.system_name}-${var.environment_name}-cloudtrail-insight"
  s3_bucket_name = var.s3_cloudtrail_logs_bucket_name
  s3_key_prefix  = "insight"
  enable_logging = true  # 作成される場合は常に有効
  is_multi_region_trail         = var.is_multi_region_trail
  enable_log_file_validation    = var.enable_log_file_validation
  # インサイトイベントの設定
  insight_selector {
    insight_type = "ApiCallRateInsight"
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-cloudtrail-insight"
  }
}