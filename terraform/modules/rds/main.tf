# Aurora MySQL クラスターの作成
resource "aws_rds_cluster" "aurora_mysql_cluster" {
  cluster_identifier      = "${var.system_name}-${var.environment_name}-rds-aurora"
  engine                  = "aurora-mysql"
  engine_version          = var.engine_version
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  vpc_security_group_ids  = [var.security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.system_name}-${var.environment_name}-final-snapshot"
  deletion_protection     = var.deletion_protection
  
  # 必要に応じてKMSキーを設定
  storage_encrypted       = var.storage_encrypted
  kms_key_id              = var.kms_key_id
  
  tags = {
    Name = "${var.system_name}-${var.environment_name}-rds-aurora"
  }
}

# サブネットグループ作成
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "${var.system_name}-${var.environment_name}-aurora-subnet-group"
  subnet_ids = var.subnet_ids
  
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-subnet-group"
  }
}

# Aurora MySQL インスタンス作成（1つのAZのみ）
resource "aws_rds_cluster_instance" "aurora_instance" {
  count                   = 1
  identifier              = "${var.system_name}-${var.environment_name}-aurora-instance-${count.index}"
  cluster_identifier      = aws_rds_cluster.aurora_mysql_cluster.id
  instance_class          = var.instance_class
  engine                  = "aurora-mysql"
  engine_version          = var.engine_version
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  availability_zone       = "${var.region}a"  # AZのaにのみデプロイ
  
  tags = {
    Name = "${var.system_name}-${var.environment_name}-aurora-instance-${count.index}"
  }
} 