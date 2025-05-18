# リソースの定義
## データリソース（現在のAWSアカウントのIDを取得）
data "aws_caller_identity" "terra_caller_identity" {} 

## バケット定義
locals {
  buckets = {
    app_contents = {
      name = "${var.system_name}-${var.environment_name}-app-contents"
      lifecycle_rule = false
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Principal = {
              AWS = "arn:aws:iam::${data.aws_caller_identity.terra_caller_identity.account_id}:user/hamasoron"
            }
            Action = "s3:*"
            Resource = [
              "arn:aws:s3:::${var.system_name}-${var.environment_name}-app-contents/*"
            ]
          }
        ]
      })
    },
    alb_logs = {
      name = "${var.system_name}-${var.environment_name}-alb-logs"
      lifecycle_rule = true
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Principal = {
              AWS = "arn:aws:iam::582318560864:root"
            }
            Action = "s3:PutObject"
            Resource = [
              "arn:aws:s3:::${var.system_name}-${var.environment_name}-alb-logs/accesslogs/AWSLogs/${data.aws_caller_identity.terra_caller_identity.account_id}/*",
              "arn:aws:s3:::${var.system_name}-${var.environment_name}-alb-logs/connectionlogs/AWSLogs/${data.aws_caller_identity.terra_caller_identity.account_id}/*"
            ]
          }
        ]
      })
    }
  }
  # contentsバケット内に疑似フォルダ構造を作成するための定義
  folder_structure = [
    "srep1/",
    "srep1/app/",
    "srep1/app/api-python/",
    "srep1/app/db-initdata/",
    "srep1/app/db-inituser/",
    "srep1/app/front-nginx/"
  ]
}

## S3バケットの作成
resource "aws_s3_bucket" "terra_s3_bucket" {
  for_each      = local.buckets
  bucket        = each.value.name
  force_destroy = var.force_destroy
  tags = {
    Name = each.value.name
  }
}

## S3バケットのパブリックアクセスブロック
resource "aws_s3_bucket_public_access_block" "terra_s3_bucket_public_access_block" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.terra_s3_bucket[each.key].id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

## S3バケットのSSE-S3暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "terra_s3_bucket_server_side_encryption_configuration" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.terra_s3_bucket[each.key].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

## S3バケットの所有者設定
resource "aws_s3_bucket_ownership_controls" "terra_s3_bucket_ownership_controls" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.terra_s3_bucket[each.key].id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

## S3バケットのバケットポリシー
resource "aws_s3_bucket_policy" "terra_s3_bucket_policy" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.terra_s3_bucket[each.key].id
  policy   = each.value.policy
}

## S3バケットのライフサイクルポリシー（条件付き）
resource "aws_s3_bucket_lifecycle_configuration" "terra_s3_bucket_lifecycle_configuration" {
  for_each = {
    for k, v in local.buckets : k => v if v.lifecycle_rule
  }
  bucket = aws_s3_bucket.terra_s3_bucket[each.key].id
  rule {
    id     = "log-expiration"
    status = "Enabled"
    filter {
      prefix = ""
    }
    expiration {
      days = var.log_expiration_days
    }
  }
}

## contentsバケットの疑似フォルダ構造を作成
resource "aws_s3_object" "folder_structure" {
  for_each = toset(local.folder_structure)
  bucket   = aws_s3_bucket.terra_s3_bucket["app_contents"].id
  key      = each.value
  content  = ""
  tags = {
    Name = each.value
  }
}