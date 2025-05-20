# アウトプットの定義
## Route53_zone
output "route53_zone_id" {
  description = "作成されたRoute53ホストゾーンのID（ACMモジュールの証明書のドメイン検証等に使用）"
  value = aws_route53_zone.terra_route53_zone.zone_id
}

output "route53_zone_name" {
  description = "作成されたRoute53ホストゾーンの名前（Route53のホストゾーン名をACMモジュールの証明書のドメイン名として使用）"
  value = aws_route53_zone.terra_route53_zone.name
}

output "route53_zone_name_servers" {
  description = "作成されたRoute53ホストゾーンのネームサーバー（ValueDomain等の外部レジストラにRoute53のNSレコードをコピーする際に使用）"
  value = aws_route53_zone.terra_route53_zone.name_servers
}