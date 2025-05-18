# リソースの定義
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
  apply_immediately       = var.apply_immediately
  preferred_maintenance_window = var.preferred_maintenance_window_cluster
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  vpc_security_group_ids  = [var.rds_security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.terra_db_subnet_group.name
  copy_tags_to_snapshot   = var.copy_tags_to_snapshot
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-cluster"
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

## Aurora MySQL インスタンス作成（1つのAZのみ）
resource "aws_rds_cluster_instance" "terra_rds_cluster_instance" {
  count                   = 1
  identifier              = "${var.system_name}-${var.environment_name}-aurora-instance-${count.index}"
  cluster_identifier      = aws_rds_cluster.terra_rds_cluster.id
  promotion_tier          = var.promotion_tier
  instance_class          = var.instance_class
  engine                  = var.db_engine
  engine_version          = var.engine_version
  availability_zone       = "${var.region_name}a"
  apply_immediately       = var.apply_immediately
  preferred_maintenance_window = var.preferred_maintenance_window_instanceA
  db_subnet_group_name    = aws_db_subnet_group.terra_db_subnet_group.name
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-instance-${count.index}"
  }
} 