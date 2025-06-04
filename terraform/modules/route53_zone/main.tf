# リソースの定義
## Route53ゾーンの作成（パブリックホストゾーン）
resource "aws_route53_zone" "terra_route53_zone" {
  name          = "${var.system_name}.jp"
  comment       = "Public hosted zone for ${var.system_name}.jp (${var.environment_name})"
  force_destroy = var.route53_force_destroy
  tags = {
    "Name" = "${var.system_name}-${var.environment_name}-route53-hostzone"
  }
}

## Route53レコードの作成（CAAレコード）
resource "aws_route53_record" "terra_route53_record_caa" {
  zone_id = aws_route53_zone.terra_route53_zone.zone_id
  name = "${var.system_name}.jp" ##### ドメインの全てのサブドメイン（dev/stg）にも継承
  type = "CAA" ##### Certificate Authority Authorization
  ttl = 3600
  records = var.caa_records
}