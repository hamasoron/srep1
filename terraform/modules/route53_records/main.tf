# ローカル変数の定義
## Aliasレコードのレコード名を設定
### prodの場合は、system_name.jp、それ以外の場合は、environment_name.system_name.jp）
locals {
  route53_record_name = var.environment_name == "prod" ? "${var.system_name}.jp" : "${var.environment_name}.${var.system_name}.jp"
}

# メインの定義
## Route53レコードの作成（Aliasレコード）
resource "aws_route53_record" "terra_route53_record_alias" {
  zone_id = var.route53_zone_id
  name = local.route53_record_name
  type = "A"
  alias {
    name = var.alb_dns_name
    zone_id = var.alb_zone_id
    evaluate_target_health = false
  }
}