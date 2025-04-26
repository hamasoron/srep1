# アウトプットの定義
## VPC
output "vpc_id" {
  description = "VPCのID"
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "サブネットのID"
  value = module.vpc.subnet_ids
}

output "public_subnet_ids" {
  description = "パブリックサブネットのID"
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "プライベートサブネットのID"
  value = module.vpc.private_subnet_ids
}

output "protected_subnet_ids" {
  description = "保護されたサブネットのID"
  value = module.vpc.protected_subnet_ids
}

output "internet_gateway_id" {
  description = "インターネットゲートウェイのID"
  value = module.vpc.internet_gateway_id
}

output "nat_gateway_eip_id" {
  description = "NATゲートウェイ用のEIPのID（条件付き）"
  value       = module.vpc.nat_gateway_eip_id
}

output "nat_gateway_id" {
  description = "NATゲートウェイのID（条件付き）"
  value = module.vpc.nat_gateway_id
}

output "route_table_ids" {
  description = "ルートテーブルのID"
  value = module.vpc.route_table_ids
}

output "route_table_association_ids" {
  description = "サブネットとルートテーブルの関連付けのID"
  value = module.vpc.route_table_association_ids
}

output "s3_vpc_endpoint_id" {
  description = "S3のVPCエンドポイントのID"
  value = module.vpc.s3_vpc_endpoint_id
}

output "dynamodb_vpc_endpoint_id" {
  description = "DynamoDBのVPCエンドポイントのID"
  value = module.vpc.dynamodb_vpc_endpoint_id
}

output "protected_subnet_resource_ids" {
  description = "リソースIDとしてのProtectedサブネットID一覧（依存関係解決用）"
  value = module.vpc.protected_subnet_resource_ids
}

## セキュリティグループ
output "security_group_ids" {
  description = "セキュリティグループのID"
  value = module.sg.security_group_ids
}

## IAMロール
output "ecs_task_role_arn" {
  description = "ECSタスク用のIAMロールのARN"
  value = module.iamrole.ecs_task_role_arn
}

output "ecs_task_execution_role_arn" {
  description = "ECSタスク実行用のIAMロールのARN"
  value = module.iamrole.ecs_task_execution_role_arn
}

output "github_actions_role_arn" {
  description = "GitHub Actions用のIAMロールのARN"
  value = module.iamrole.github_actions_role_arn
}

## RDS
output "cluster_id" {
  description = "AuroraクラスターのID"
  value = module.rds.cluster_id
}

output "cluster_endpoint" {
  description = "Auroraクラスターのエンドポイント"
  value = module.rds.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Auroraクラスターのリーダーエンドポイント"
  value = module.rds.cluster_reader_endpoint
}

output "cluster_port" {
  description = "Auroraクラスターのポート番号"
  value = module.rds.cluster_port
}

output "instance_ids" {
  description = "AuroraインスタンスのID"
  value = module.rds.instance_ids
}

output "db_name" {
  description = "データベース名"
  value = module.rds.db_name
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







