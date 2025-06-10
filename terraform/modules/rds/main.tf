# ローカル変数の定義
## Aurora設定の自動計算ロジック
locals {
  ### AZ数の自動計算（available_azs_namesのlengthから取得）
  available_azs_count = length(var.available_azs_names)
  ### deployment_modeとAZ数に基づくインスタンス数の決定
  deployment_config = {
    ##### AZ数が1の場合の構成（単一AZ環境）
    1 = {
      writer_only           = { count = 1, writer_count = 1, reader_count = 0 }
      writer_with_1_reader  = { count = 1, writer_count = 1, reader_count = 0 } ##### 1AZではReader不可
      writer_with_2_readers = { count = 1, writer_count = 1, reader_count = 0 } ##### 1AZではReader不可
    }
    #### AZ数が2の場合の構成
    2 = {
      writer_only           = { count = 1, writer_count = 1, reader_count = 0 }
      writer_with_1_reader  = { count = 2, writer_count = 1, reader_count = 1 }
      writer_with_2_readers = { count = 2, writer_count = 1, reader_count = 1 } ##### 2AZでは最大2台まで
    }
    #### AZ数が3の場合の構成
    3 = {
      writer_only           = { count = 1, writer_count = 1, reader_count = 0 }
      writer_with_1_reader  = { count = 2, writer_count = 1, reader_count = 1 }
      writer_with_2_readers = { count = 3, writer_count = 1, reader_count = 2 }
    }
  }
  ### 現在のAZ数の正規化（東京リージョンでは1-3AZの範囲で制限）
  current_az_count = min(max(local.available_azs_count, 1), 3)
  ### 選択されたデプロイメント構成
  selected_config = local.deployment_config[local.current_az_count][var.deployment_mode]
  final_instance_count = local.selected_config.count
  ### AZ配置戦略（VPCから取得したAZを順番に使用）
  instance_azs = slice(var.available_azs_names, 0, min(local.final_instance_count, length(var.available_azs_names)))
  ### プロモーション階層の設定（writer=0、reader=1）
  promotion_tiers = [for i in range(local.final_instance_count) : i == 0 ? 0 : 1]
  
  ### メンテナンスウィンドウの自動生成（基準時刻から動的に計算）
  #### 基準時刻（var.preferred_maintenance_window_base）から情報を抽出（形式：tue:17:15-tue:17:45）
  base_start_part = split("-", var.preferred_maintenance_window_base)[0]  ##### 「-」で区切る。"tue:17:15"
  base_parts = split(":", local.base_start_part)  ##### 「:」で区切る。["tue", "17", "15"]
  base_day = local.base_parts[0]
  base_hour = tonumber(local.base_parts[1])
  base_minute = tonumber(local.base_parts[2])
  ### 各インスタンス用のメンテナンスウィンドウを生成
  maintenance_windows = [
    for i in range(local.final_instance_count) : 
    i == 0 ? var.preferred_maintenance_window_base : format(
      "%s:%02d:%02d-%s:%02d:%02d",
      local.base_day,
      floor((local.base_minute + i * 30) / 60) + local.base_hour,
      (local.base_minute + i * 30) % 60,
      local.base_day,
      floor((local.base_minute + i * 30 + 30) / 60) + local.base_hour,
      (local.base_minute + i * 30 + 30) % 60
    )
  ]
}

# リソースの定義
## クラスター用の一意なスナップショットIDの生成（skip_final_snapshotがfalseの場合に使用）
resource "random_id" "final_snapshot_id" {
  byte_length = 4 ##### 4バイトの16進数（8桁のランダムなIDを生成後に接尾辞として使用）
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

## インスタンスパラメータグループ作成
resource "aws_db_parameter_group" "terra_db_parameter_group" {
  name        = "${var.system_name}-${var.environment_name}-aurora-instance-paramgrp"
  family      = "aurora-mysql8.0"
  description = "Aurora MySQL 8.0 instance parameter group for ${var.system_name}-${var.environment_name}"
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-instance-paramgrp"
  }
}

## サブネットグループ作成
resource "aws_db_subnet_group" "terra_db_subnet_group" {
  name       = "${var.system_name}-${var.environment_name}-aurora-subgrp"
  description = "Aurora MySQL 8.0 subnet group for ${var.system_name}-${var.environment_name}"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-subgrp"
  }
}

## Aurora MySQL クラスターの作成
resource "aws_rds_cluster" "terra_rds_cluster" {
  cluster_identifier      = "${var.system_name}-${var.environment_name}-aurora-cluster"
  engine                  = var.db_engine
  engine_version          = var.engine_version
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period ##### 自動バックアップの保持期間（日数）
  preferred_backup_window = var.preferred_backup_window ##### 自動バックアップの実行時間帯（UTC）
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.system_name}-${var.environment_name}-aurora-final-${random_id.final_snapshot_id.hex}"
  deletion_protection     = var.deletion_protection
  storage_encrypted       = var.storage_encrypted
  kms_key_id              = var.rds_kms_key_id
  apply_immediately       = var.apply_immediately ##### parameter groupの変更を即時反映するかメンテナンス時に反映するかどうか
  preferred_maintenance_window = var.preferred_maintenance_window_cluster ##### メンテナンスウィンドウの時間帯（UTC）
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  monitoring_interval = var.monitoring_interval ##### モニタリングの間隔（秒）
  monitoring_role_arn = var.monitoring_role_arn ##### モニタリングのロールARN
  vpc_security_group_ids  = [var.rds_security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.terra_db_subnet_group.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.terra_rds_cluster_parameter_group.name
  copy_tags_to_snapshot   = var.copy_tags_to_snapshot
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-cluster"
  }
}

## Aurora MySQL インスタンス作成（環境・AZ数に応じた台数）
resource "aws_rds_cluster_instance" "terra_rds_cluster_instance" {
  count                   = local.final_instance_count
  identifier              = "${var.system_name}-${var.environment_name}-aurora-instance-${count.index}"
  cluster_identifier      = aws_rds_cluster.terra_rds_cluster.id
  availability_zone       = local.instance_azs[count.index]
  promotion_tier          = local.promotion_tiers[count.index]
  instance_class          = var.instance_class
  engine                  = var.db_engine
  engine_version          = var.engine_version
  apply_immediately       = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  preferred_maintenance_window = local.maintenance_windows[count.index]
  publicly_accessible = var.publicly_accessible
  db_subnet_group_name    = aws_db_subnet_group.terra_db_subnet_group.name
  db_parameter_group_name = aws_db_parameter_group.terra_db_parameter_group.name
  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-instance-${count.index}"
  }
} 