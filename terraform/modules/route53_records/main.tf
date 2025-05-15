# メインの定義
## Route53レコードの作成（Aliasレコード）
resource "aws_route53_record" "terra_route53_record_alias" {
  zone_id = var.route53_zone_id
  name = "${var.environment_name}.${var.system_name}.jp"
  type = "A"
  alias {
    name = var.alb_dns_name
    zone_id = var.alb_zone_id
    evaluate_target_health = false
  }
}
