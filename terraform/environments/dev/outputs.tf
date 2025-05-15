# アウトプットの定義
## Route53_zone
output "route53_zone_id" {
  description = "作成されたRoute53ホストゾーンのID（ACMモジュールでの証明書のドメイン検証に使用）"
  value = module.route53_zone.route53_zone_id
}

output "route53_zone_name" {
  description = "作成されたRoute53ホストゾーンの名前（Route53のホストゾーン名をACMモジュール内で証明書のドメイン名として使用）"
  value = module.route53_zone.route53_zone_name
}

output "route53_zone_name_servers" {
  description = "作成されたRoute53ホストゾーンのネームサーバー（ValueDomain等の外部レジストラにRoute53のNSレコードをコピーする際に使用）"
  value = module.route53_zone.route53_zone_name_servers
}

## ACM
output "certificate_arn" {
  description = "ACM証明書のARN（ALBモジュールやCloudFrontモジュールなどで証明書を設定する際に使用）"
  value = module.acm.certificate_arn
}

## VPC
output "create_protected_ngw_associations" {
  description = "プロテクテッドサブネット及びNATゲートウェイ関連の作成有無（ECSモジュール等で使用）"
  value = module.vpc.create_protected_ngw_associations
}

output "vpc_id" {
  description = "VPCのID（SGやALBモジュールなどでVPCを指定する際に使用）"
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "サブネットのID（AZやNAT構成に応じて動的に変化する全てのサブネットのIDを必ず取得。ECSモジュール等で使用）"
  value = module.vpc.subnet_ids
}

output "public_subnet_ids" {
  description = "パブリックサブネットのID（AZやNAT構成に応じて動的に変化するパブリックサブネットのIDを必ず取得。ALBモジュール等で使用）"
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "プライベートサブネットのID（AZやNAT構成に応じて動的に変化するプライベートサブネットのIDを必ず取得。RDSモジュール等で使用）"
  value = module.vpc.private_subnet_ids
}

output "protected_subnet_ids" {
  description = "プロテクテッドサブネットのID（AZやNAT構成に応じて動的に変化するプロテクテッドサブネットのIDを必ず取得）"
  value = module.vpc.protected_subnet_ids
}

output "route_table_ids" {
  description = "ルートテーブルのID（AZやNAT構成に応じて動的に変化する全てのルートテーブルのIDを必ず取得）"
  value = module.vpc.route_table_ids
}

## セキュリティグループ
output "security_group_ids" {
  description = "セキュリティグループのID（RDSやALBやECSモジュール等で使用）"
  value = module.sg.security_group_ids
}

## IAMロール
output "ecs_task_role_arn" {
  description = "ECSタスク用のIAMロールのARN（ECSモジュール等で使用）"
  value = module.iamrole.ecs_task_role_arn
}

output "ecs_task_execution_role_arn" {
  description = "ECSタスク実行用のIAMロールのARN（ECSモジュール等で使用）"
  value = module.iamrole.ecs_task_execution_role_arn
}

output "github_actions_role_arn" {
  description = "GitHub Actions用のIAMロールのARN"
  value = module.iamrole.github_actions_role_arn
}

## SecretsManager
output "rds_master_secret_arn" {
  description = "RDS master user secretのARN（ECSモジュールの環境変数の設定等で使用）"
  value = module.secretsmanager.rds_master_secret_arn
}

output "rds_app_secret_arn" {
  description = "RDS app user secretのARN（ECSモジュールの環境変数の設定等で使用）"
  value = module.secretsmanager.rds_app_secret_arn
}

## RDS
output "cluster_id" {
  description = "AuroraクラスターのID"
  value = module.rds.cluster_id
}

output "cluster_endpoint" {
  description = "Auroraクラスターのエンドポイント（ECSモジュールの環境変数の設定等で使用）"
  value = module.rds.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Auroraクラスターのリーダーエンドポイント（ECSモジュールの環境変数の設定等で使用）"
  value = module.rds.cluster_reader_endpoint
}

output "cluster_port" {
  description = "Aurora クラスターのポート番号（ECSモジュールの環境変数の設定等で使用）"
  value = module.rds.cluster_port
}

output "cluster_database_name" {
  description = "Aurora クラスターのデフォルトデータベース名（ECSモジュールの環境変数の設定等で使用）"
  value = module.rds.cluster_database_name
}

## S3
output "alb_logs_bucket_name" {
  description = "ALBログバケットの名前"
  value = module.s3.alb_logs_bucket_name
}

output "alb_logs_bucket_arn" {
  description = "ALBログバケットのARN"
  value = module.s3.alb_logs_bucket_arn
}

## ALB
output "alb_arn" {
  description = "ALBのARN"
  value = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "ALBのDNS名"
  value = module.alb.alb_dns_name
}

output "front_target_group_arn" {
  description = "フロントエンドターゲットグループのARN"
  value = module.alb.front_target_group_arn
}

output "front_target_group_name" {
  description = "フロントエンドターゲットグループの名前"
  value = module.alb.front_target_group_name
}

## Route53_records
output "route53_alias_record_fqdn" {
  description = "AliasレコードのFQDN"
  value = module.route53_records.route53_alias_record_fqdn
}

## ECR
output "repositories_url" {
  description = "ECRリポジトリのURL（マップ形式）"
  value = module.ecr.repositories_url
}

output "repositories_arn" {
  description = "ECRリポジトリのARN（マップ形式）"
  value = module.ecr.repositories_arn
}

output "api_repository_url" {
  description = "APIリポジトリのURL (ECS連携用)"
  value = module.ecr.api_repository_url
}

output "front_repository_url" {
  description = "フロントエンドリポジトリのURL (ECS連携用)"
  value = module.ecr.front_repository_url
}

## CloudWatch Logs
output "api_log_group_name" {
  description = "API用CloudWatch Logsグループの名前"
  value = module.cloudwatch_logs.log_group_names["api-python"]
}

# output "api_service_connect_log_group_name" {
#   description = "API Service Connect用CloudWatch Logsグループの名前"
#   value = module.cloudwatch_logs.service_connect_log_group_names["api-python"]
# }

output "front_log_group_name" {
  description = "フロントエンド用CloudWatch Logsグループの名前"
  value = module.cloudwatch_logs.log_group_names["front-nginx"]
}

# output "front_service_connect_log_group_name" {
#   description = "フロントエンド Service Connect用CloudWatch Logsグループの名前"
#   value = module.cloudwatch_logs.service_connect_log_group_names["front-nginx"]
# }

output "db_initdata_log_group_name" {
  description = "DB初期データ用CloudWatch Logsグループの名前"
  value = module.cloudwatch_logs.log_group_names["db-initdata"]
}

## ECS
output "ecs_cluster_id" {
  description = "ECSクラスターのID"
  value = module.ecs.ecs_cluster_id
}

output "ecs_cluster_name" {
  description = "ECSクラスターの名前"
  value = module.ecs.ecs_cluster_name
}

output "ecs_api_service_id" {
  description = "ECS APIサービスのID"
  value = module.ecs.ecs_api_service_id
}

output "ecs_api_service_name" {
  description = "ECS APIサービスの名前"
  value = module.ecs.ecs_api_service_name
}

output "ecs_front_service_id" {
  description = "ECS フロントエンドサービスのID"
  value = module.ecs.ecs_front_service_id
}

output "ecs_front_service_name" {
  description = "ECS フロントエンドサービスの名前"
  value = module.ecs.ecs_front_service_name
}

output "ecs_api_task_definition_arn" {
  description = "ECS APIタスク定義のARN"
  value = module.ecs.ecs_api_task_definition_arn
}

output "ecs_front_task_definition_arn" {
  description = "ECS フロントエンドタスク定義のARN"
  value = module.ecs.ecs_front_task_definition_arn
}