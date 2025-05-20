# メインの定義
## ACM（DV）証明書の作成
resource "aws_acm_certificate" "terra_acm_certificate" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name        = "${var.system_name}-${var.environment_name}-acm-certificate"
  }
}

## ACM（DV）証明書の検証
resource "aws_acm_certificate_validation" "terra_acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.terra_acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.terra_acm_certificate_validation_record : record.fqdn]
}

## Route53レコード（CNAME）の作成
resource "aws_route53_record" "terra_acm_certificate_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.terra_acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true ##### 同名レコードがある場合は上書きするかどうか
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = var.route53_zone_id
} 