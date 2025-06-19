# リソースの定義
## データリソース（現在のAWSアカウントのIDとリージョンを取得）
data "aws_caller_identity" "terra_caller_identity" {}
data "aws_region" "terra_current" {} 

## バケット定義
locals {
  buckets = {
    app_contents = {
      name = "${var.system_name}-${var.environment_name}-app-contents"
      lifecycle_rule = true
      policy = null
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
              AWS = "arn:aws:iam::582318560864:root"  # ALB service account for ap-northeast-1
            }
            Action = "s3:PutObject"
            Resource = [
              "arn:aws:s3:::${var.system_name}-${var.environment_name}-alb-logs/accesslogs/AWSLogs/${data.aws_caller_identity.terra_caller_identity.account_id}/*",
              "arn:aws:s3:::${var.system_name}-${var.environment_name}-alb-logs/connectionlogs/AWSLogs/${data.aws_caller_identity.terra_caller_identity.account_id}/*"
            ]
          },
          {
            Effect = "Allow"
            Principal = {
              Service = "delivery.logs.amazonaws.com"
            }
            Action = "s3:GetBucketAcl"
            Resource = "arn:aws:s3:::${var.system_name}-${var.environment_name}-alb-logs"
          }
        ]
      })
    },
    cloudtrail_logs = {
      name = "${var.system_name}-${var.environment_name}-cloudtrail-logs"
      lifecycle_rule = true
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Principal = {
              Service = "cloudtrail.amazonaws.com"
            }
            Action = "s3:GetBucketAcl"
            Resource = "arn:aws:s3:::${var.system_name}-${var.environment_name}-cloudtrail-logs"
          },
          {
            Effect = "Allow"
            Principal = {
              Service = "cloudtrail.amazonaws.com"
            }
            Action = "s3:PutObject"
            Resource = [
              "arn:aws:s3:::${var.system_name}-${var.environment_name}-cloudtrail-logs/management/AWSLogs/${data.aws_caller_identity.terra_caller_identity.account_id}/*",
              "arn:aws:s3:::${var.system_name}-${var.environment_name}-cloudtrail-logs/data/AWSLogs/${data.aws_caller_identity.terra_caller_identity.account_id}/*",
              "arn:aws:s3:::${var.system_name}-${var.environment_name}-cloudtrail-logs/insight/AWSLogs/${data.aws_caller_identity.terra_caller_identity.account_id}/*"
            ]
            Condition = {
              StringEquals = {
                "s3:x-amz-acl" = "bucket-owner-full-control"
              }
            }
          }
        ]
      })
    },
    vpc_flow_logs = {
      name = "${var.system_name}-${var.environment_name}-vpc-flow-logs"
      lifecycle_rule = true
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid = "AWSLogDeliveryWrite"
            Effect = "Allow"
            Principal = {
              Service = "delivery.logs.amazonaws.com"
            }
            Action = "s3:PutObject"
            Resource = "arn:aws:s3:::${var.system_name}-${var.environment_name}-vpc-flow-logs/AWSLogs/${data.aws_caller_identity.terra_caller_identity.account_id}/*"
            Condition = {
              StringEquals = {
                "aws:SourceAccount" = data.aws_caller_identity.terra_caller_identity.account_id
                "s3:x-amz-acl" = "bucket-owner-full-control"
              }
              ArnLike = {
                "aws:SourceArn" = "arn:aws:logs:${data.aws_region.terra_current.name}:${data.aws_caller_identity.terra_caller_identity.account_id}:*"
              }
            }
          },
          {
            Sid = "AWSLogDeliveryAclCheck"
            Effect = "Allow"
            Principal = {
              Service = "delivery.logs.amazonaws.com"
            }
            Action = "s3:GetBucketAcl"
            Resource = "arn:aws:s3:::${var.system_name}-${var.environment_name}-vpc-flow-logs"
            Condition = {
              StringEquals = {
                "aws:SourceAccount" = data.aws_caller_identity.terra_caller_identity.account_id
              }
              ArnLike = {
                "aws:SourceArn" = "arn:aws:logs:${data.aws_region.terra_current.name}:${data.aws_caller_identity.terra_caller_identity.account_id}:*"
              }
            }
          }
        ]
      })
    },
    waf_logs = {
      name = "aws-waf-logs-${var.system_name}-${var.environment_name}-waf-logs"
      lifecycle_rule = true
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Principal = {
              Service = "firehose.amazonaws.com"
            }
            Action = [
              "s3:AbortMultipartUpload",
              "s3:GetBucketLocation",
              "s3:GetObject",
              "s3:ListBucket",
              "s3:ListBucketMultipartUploads",
              "s3:PutObject"
            ]
            Resource = [
              "arn:aws:s3:::aws-waf-logs-${var.system_name}-${var.environment_name}-waf-logs",
              "arn:aws:s3:::aws-waf-logs-${var.system_name}-${var.environment_name}-waf-logs/*"
            ]
          }
        ]
      })
    }
  }

  ### contentsバケット内に疑似フォルダ構造を作成するための定義
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
  block_public_acls       = true ##### acl関連の設定
  ignore_public_acls      = true ##### acl関連の設定
  block_public_policy     = true ##### パブリックアクセス関連の設定
  restrict_public_buckets = true ##### パブリックアクセス関連の設定
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
  for_each = {
    for k, v in local.buckets : k => v if v.policy != null
  }
  bucket   = aws_s3_bucket.terra_s3_bucket[each.key].id
  policy   = each.value.policy
}

## S3バケットの初期化待機（ライフサイクルポリシーの作成時点でバケットが作成されない問題を事前に回避）
resource "time_sleep" "wait_for_logging_bucket_initialization" {
  depends_on = [
    aws_s3_bucket.terra_s3_bucket,
    aws_s3_bucket_policy.terra_s3_bucket_policy
  ]
  create_duration = "30s"
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
  depends_on = [
    time_sleep.wait_for_logging_bucket_initialization,
  ]
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