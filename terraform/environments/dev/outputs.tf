# アウトプットの定義
## Route53 Zone
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
output "acm_certificate_arn" {
  description = "ACM証明書のARN（ALBモジュール等で証明書を設定する際に使用）"
  value = module.acm.acm_certificate_arn
}

## VPC
output "vpc_create_protected_ngw_associations" {
  description = "プロテクテッドサブネット及びNATゲートウェイ関連の作成有無（ECSモジュール等で使用）"
  value = module.vpc.vpc_create_protected_ngw_associations
}

output "vpc_id" {
  description = "VPCのID（SGやALBモジュールなどでVPCを指定する際に使用）"
  value = module.vpc.vpc_id
}

output "vpc_public_subnet_ids" {
  description = "パブリックサブネットのID（AZやNAT構成に応じて動的に変化するパブリックサブネットのIDを必ず取得。ALBモジュール等で使用）"
  value = module.vpc.vpc_public_subnet_ids
}

output "vpc_private_subnet_ids" {
  description = "プライベートサブネットのID（AZやNAT構成に応じて動的に変化するプライベートサブネットのIDを必ず取得。RDSモジュール等で使用）"
  value = module.vpc.vpc_private_subnet_ids
}

output "vpc_protected_subnet_ids" {
  description = "プロテクテッドサブネットのID（AZやNAT構成に応じて動的に変化するプロテクテッドサブネットのIDを必ず取得）"
  value = module.vpc.vpc_protected_subnet_ids
}

output "vpc_route_table_ids" {
  description = "ルートテーブルのID"
  value = module.vpc.vpc_route_table_ids
}

## SG
output "sg_security_group_ids" {
  description = "セキュリティグループのID（RDSやALBやECSモジュール等で使用）"
  value = module.sg.sg_security_group_ids
}

## IAM Role
output "iam_role_ecs_task_role_arn" {
  description = "ECSタスク用のIAMロールのARN（ECSモジュール等で使用）"
  value = module.iam_role.iam_role_ecs_task_role_arn
}

output "iam_role_ecs_task_execution_role_arn" {
  description = "ECSタスク実行用のIAMロールのARN（ECSモジュール等で使用）"
  value = module.iam_role.iam_role_ecs_task_execution_role_arn
}

output "iam_role_github_actions_role_arn" {
  description = "GitHub Actions用のIAMロールのARN（GitHubのSecrets and VariablesのAWS_ROLE_TO_ASSUMEにコピーする際に使用）"
  value = module.iam_role.iam_role_github_actions_role_arn
}

output "iam_role_lambda_rotation_arn" {
  description = "Lambda関数用のIAMロールのARN（Lambdaモジュール等で使用）"
  value = module.iam_role.iam_role_lambda_rotation_arn
}

## IAM AccessAnalyzer
output "iam_accessanalyzer_arn" {
  description = "アナライザーのARN"
  value = module.iam_accessanalyzer.iam_accessanalyzer_arn
}

## CloudWatch Logs
output "rds_log_group_names" {
  description = "マップ形式のCloudWatchロググループの名前一覧（RDSモジュールのロググループ名として使用）"
  value = module.cloudwatch_logs.rds_log_group_names
}

output "ecs_log_group_names" {
  description = "マップ形式のCloudWatchロググループの名前一覧（ECSモジュールのタスク定義のロググループ名として使用）"
  value = module.cloudwatch_logs.ecs_log_group_names
}

## Secrets Manager
output "secretsmanager_secret_arns" {
  description = "マップ形式のシークレットのARN（Lambdaモジュールのシークレット関連で使用）"
  value = module.secretsmanager.secretsmanager_secret_arns
}

output "secretsmanager_master_credentials_json" {
  description = "マスターユーザーの認証情報（RDSモジュールのmaster_usernameとmaster_passwordに使用）"
  value = module.secretsmanager.secretsmanager_master_credentials_json
  sensitive = true
}

## RDS
output "rds_cluster_id" {
  description = "AuroraクラスターのID"
  value = module.rds.rds_cluster_id
}

output "rds_cluster_writer_endpoint" {
  description = "Auroraクラスターの書き込み用エンドポイント（ECSモジュールの環境変数の設定等で使用）"
  value = module.rds.rds_cluster_writer_endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "Auroraクラスターの読み込み用エンドポイント（ECSモジュールの環境変数の設定等で使用）"
  value = module.rds.rds_cluster_reader_endpoint
}

output "rds_cluster_port" {
  description = "Aurora クラスターのポート番号（ECSモジュールの環境変数の設定等で使用）"
  value = module.rds.rds_cluster_port
}

output "rds_cluster_database_name" {
  description = "Aurora クラスターのデフォルトデータベース名（ECSモジュールの環境変数の設定等で使用）"
  value = module.rds.rds_cluster_database_name
}

## Lambda
output "lambda_function_arn" {
  description = "Lambda関数のARN"
  value = module.lambda.lambda_function_arn
}

## S3
output "s3_app_contents_bucket_name" {
  description = "アプリケーションのコンテンツバケットの名前"
  value = module.s3.s3_app_contents_bucket_name
}

output "s3_alb_logs_bucket_name" {
  description = "ALBのログバケットの名前（ALBモジュールでアクセスログやコネクションログを保存するために使用）"
  value = module.s3.s3_alb_logs_bucket_name
}

## ALB
output "alb_dns_name" {
  description = "ALBのDNS名（Route53 RecordsモジュールでAliasレコードを作成する際に使用）"
  value = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "ALBのゾーンID（Route53 RecordsモジュールでAliasレコードを作成する際に使用）"
  value = module.alb.alb_zone_id
}

output "alb_front_target_group_arn" {
  description = "フロントエンドターゲットグループのARN（ECSモジュールで使用）"
  value = module.alb.alb_front_target_group_arn
}

## Route53 Records
output "route53_records_alias_record_fqdn" {
  description = "AliasレコードのFQDN（ブラウザでALBのDNS名の別名アクセスする際に使用）"
  value = module.route53_records.route53_records_alias_record_fqdn
}

## ECR
output "ecr_repository_urls" {
  description = "マップ形式のECRリポジトリのURL（ECSモジュールのタスク定義のイメージURLとして使用）"
  value = module.ecr.ecr_repository_urls
}

## ECS
output "ecs_cluster_id" {
  description = "ECSクラスターのID（GitHub Actionsで使用）"
  value = module.ecs.ecs_cluster_id
}

output "ecs_cluster_name" {
  description = "ECSクラスターの名前（ECS Exec等で使用）"
  value = module.ecs.ecs_cluster_name
}

output "ecs_api_service_name" {
  description = "ECS APIサービスの名前（ECS Exec等で使用）"
  value = module.ecs.ecs_api_service_name
}

output "ecs_front_service_name" {
  description = "ECS フロントエンドサービスの名前（ECS Exec等で使用）"
  value = module.ecs.ecs_front_service_name
}

output "ecs_api_container_name" {
  description = "ECS APIコンテナの名前（ECS Exec等で使用）"
  value = module.ecs.ecs_api_container_name
}

output "ecs_front_container_name" {
  description = "ECS フロントエンドコンテナの名前（ECS Exec等で使用）"
  value = module.ecs.ecs_front_container_name
}

output "ecs_api_task_definition_arn" {
  description = "ECS APIタスク定義のARN（GitHub Actionsで使用）"
  value = module.ecs.ecs_api_task_definition_arn
}

output "ecs_front_task_definition_arn" {
  description = "ECS フロントエンドタスク定義のARN（GitHub Actionsで使用）"
  value = module.ecs.ecs_front_task_definition_arn
}

output "ecs_db_initdata_task_definition_arn" {
  description = "ECS データ投入用タスク定義のARN（GitHub Actionsで使用）"
  value = module.ecs.ecs_db_initdata_task_definition_arn
}

output "ecs_db_inituser_task_definition_arn" {
  description = "ECS DBユーザー作成用タスク定義のARN（GitHub Actionsで使用）"
  value = module.ecs.ecs_db_inituser_task_definition_arn
}
