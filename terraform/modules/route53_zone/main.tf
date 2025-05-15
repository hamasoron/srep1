# リソースの定義
## Route53ゾーンの作成
resource "aws_route53_zone" "terra_route53_zone" {
  name          = "${var.system_name}.jp"
  comment       = "Route53 Zone for ${var.system_name}.jp"
  force_destroy = var.route53_force_destroy
  tags = {
    "Name" = "${var.system_name}-${var.environment_name}-route53-hostzone"
  }
}

## Route53レコードの作成（CAAレコード）
resource "aws_route53_record" "terra_route53_record_caa" {
  zone_id = aws_route53_zone.terra_route53_zone.zone_id
  name = "${var.environment_name}.${var.system_name}.jp"
  type = "CAA"
  ttl = 3600
  records = [
    "0 issue \"amazon.com\"",
  ]
}
