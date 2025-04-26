# リソースの定義
## データリソース（現在のAWSアカウントのIDを取得）
data "aws_caller_identity" "current" {} 

## S3バケットの作成（ALBログ用）
resource "aws_s3_bucket" "terra_s3_bucket_alb_logs" {
  bucket = "${var.system_name}-${var.environment_name}-alb-logs"
  force_destroy = var.force_destroy
  tags = {
    Name = "${var.system_name}-${var.environment_name}-alb-logs"
  }
}

## S3バケット（ALBログ用）のパブリックアクセスブロック
resource "aws_s3_bucket_public_access_block" "terra_s3_bucket_public_access_block_alb_logs" {
  bucket = aws_s3_bucket.terra_s3_bucket_alb_logs.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

## S3バケット（ALBログ用）のライフサイクルポリシー
resource "aws_s3_bucket_lifecycle_configuration" "terra_s3_bucket_lifecycle_configuration_alb_logs" {
  bucket = aws_s3_bucket.terra_s3_bucket_alb_logs.id
  rule {
    id = "log-expiration"
    status = "Enabled"
    filter {
      prefix = ""
    }
    expiration {
      days = var.log_expiration_days
    }
  }
}

## S3バケット（ALBログ用）のSSE-S3暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "terra_s3_bucket_server_side_encryption_configuration_alb_logs" {
  bucket = aws_s3_bucket.terra_s3_bucket_alb_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

## S3バケット（ALBログ用）の所有者設定
resource "aws_s3_bucket_ownership_controls" "terra_s3_bucket_ownership_controls_alb_logs" {
  bucket = aws_s3_bucket.terra_s3_bucket_alb_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

## S3バケット（ALBログ用）のポリシー
resource "aws_s3_bucket_policy" "terra_s3_bucket_policy_alb_logs" {
  bucket = aws_s3_bucket.terra_s3_bucket_alb_logs.id
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
          "${aws_s3_bucket.terra_s3_bucket_alb_logs.arn}/accesslogs/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
          "${aws_s3_bucket.terra_s3_bucket_alb_logs.arn}/connectionlogs/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        ]
      }
    ]
  })
}