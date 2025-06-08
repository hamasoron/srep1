# リソースの定義
## Aurora設定の自動計算ロジック
locals {
  ### インスタンス数の決定（環境とAZ数に基づく自動計算）
  auto_calculated_count = {
    # dev環境：常に1台（1a）
    dev = 1
    # stg・prod環境：AZ数と可用性戦略に応じて決定
    stg = var.available_azs_count >= 3 ? (var.use_all_azs_for_aurora ? 3 : 2) : 2
    prod = var.available_azs_count >= 3 ? (var.use_all_azs_for_aurora ? 3 : 2) : 2
  }
  
  ### 最終的なインスタンス数（明示指定 > 自動計算）
  final_instance_count = var.cluster_instance_count != null ? var.cluster_instance_count : local.auto_calculated_count[var.environment_name]
  
  ### AZ配置戦略（VPCから取得したAZを順番に使用）
  instance_azs = slice(var.available_azs_names, 0, min(local.final_instance_count, length(var.available_azs_names)))
  
  ### プロモーション階層の設定（writer=0、reader=1）
  promotion_tiers = [for i in range(local.final_instance_count) : i == 0 ? 0 : 1]
}

## クラスター用の一意なスナップショットIDの生成（skip_final_snapshotがfalseの場合に使用）
resource "random_id" "final_snapshot_id" {
  byte_length = 4 ##### 4バイトの16進数（8桁のランダムなIDを生成後に接尾辞として使用）
}

## Aurora MySQL クラスターの作成
resource "aws_rds_cluster" "terra_rds_cluster" {
  cluster_identifier      = "${var.system_name}-${var.environment_name}-aurora-cluster"
  engine                  = var.db_engine
  engine_version          = var.engine_version
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.system_name}-${var.environment_name}-aurora-final-${random_id.final_snapshot_id.hex}"
  deletion_protection     = var.deletion_protection
  storage_encrypted       = var.storage_encrypted
  kms_key_id              = var.rds_kms_key_id
  availability_zones      = var.available_azs_names
  apply_immediately       = var.apply_immediately
  preferred_maintenance_window = var.preferred_maintenance_window_cluster
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  vpc_security_group_ids  = [var.rds_security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.terra_db_subnet_group.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.terra_rds_cluster_parameter_group.name
  copy_tags_to_snapshot   = var.copy_tags_to_snapshot
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-cluster"
  }
}

## クラスターパラメータグループ作成
resource "aws_rds_cluster_parameter_group" "terra_rds_cluster_parameter_group" {
  name        = "${var.system_name}-${var.environment_name}-aurora-cluster-paramgrp"
  family      = "aurora-mysql8.0"
  description = "Aurora MySQL 8.0 cluster parameter group for ${var.system_name}-${var.environment_name}"
  parameter {
    name  = "require_secure_transport" ##### クラスター内のすべての接続をTLS経由にする（TLSのバージョンはデフォルト値が強化されることを期待してあえて指定しない）
    value = "ON"
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-cluster-paramgrp"
  }
}

## サブネットグループ作成
resource "aws_db_subnet_group" "terra_db_subnet_group" {
  name       = "${var.system_name}-${var.environment_name}-aurora-subgrp"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-subgrp"
  }
}

## Aurora MySQL インスタンス作成（環境・AZ数に応じた台数）
resource "aws_rds_cluster_instance" "terra_rds_cluster_instance" {
  count                   = local.final_instance_count
  identifier              = "${var.system_name}-${var.environment_name}-aurora-instance-${count.index}"
  cluster_identifier      = aws_rds_cluster.terra_rds_cluster.id
  promotion_tier          = local.promotion_tiers[count.index]
  instance_class          = var.instance_class
  engine                  = var.db_engine
  engine_version          = var.engine_version
  availability_zone       = local.instance_azs[count.index]
  apply_immediately       = var.apply_immediately
  preferred_maintenance_window = var.preferred_maintenance_window_instanceA
  performance_insights_enabled    = var.enable_performance_insights
  db_subnet_group_name    = aws_db_subnet_group.terra_db_subnet_group.name
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-instance-${count.index}"
    Role = count.index == 0 ? "writer" : "reader"
    AZ   = local.instance_azs[count.index]
  }
} 