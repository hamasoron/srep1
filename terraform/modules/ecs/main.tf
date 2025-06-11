# リソースの定義
## ECSクラスターの作成
resource "aws_ecs_cluster" "terra_ecs_cluster" {
  name = "${var.system_name}-${var.environment_name}-cluster"
  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
      kms_key_id = var.ecs_kms_key_id
    }
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-cluster"
  }
}

## ECSクラスターの容量プロバイダーの設定
resource "aws_ecs_cluster_capacity_providers" "terra_ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.terra_ecs_cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy { ##### デフォルトは常にFARGATE（オンデマンド）
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

## 名前空間の作成（Private DNS用）（Cloud Map）
resource "aws_service_discovery_private_dns_namespace" "terra_service_discovery_private_dns_namespace" {
  name        = "${var.system_name}-${var.environment_name}-namespace.local"
  description = "Private DNS namespace for ${var.system_name} ${var.environment_name}"
  vpc         = var.vpc_id
  tags = {
    Name = "${var.system_name}-${var.environment_name}-namespace.local"
  }
}

## サービス名とサービスディスカバリー（DNS名でサービスを検出）の作成（Cloud Map）
resource "aws_service_discovery_service" "terra_service_discovery_service" {
  name = "api-python"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.terra_service_discovery_private_dns_namespace.id
    routing_policy = "MULTIVALUE" ##### 複数のタスクが存在する場合、それらのタスクのIPアドレスを返す（ラウンドロビン方式）
    dns_records {
      ttl  = 60
      type = "A"
    }
  }
  health_check_custom_config { ##### カスタムヘルスチェックを使用（アプリからAPIコールを行う場合のヘルスチェック）
    failure_threshold = 1
  }
  tags = {
    Name = "api-python"
  }
}

## ECSタスク定義（APIサービス用）
resource "aws_ecs_task_definition" "terra_ecs_task_definition_api" {
  family                   = "${var.system_name}-${var.environment_name}-api-python-taskdef"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.api_task_cpu
  memory                   = var.api_task_memory
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_task_execution_role_arn
  container_definitions = jsonencode([
    {
      name      = "api-python"
      image     = var.api_ecr_repository_url
      essential = true
      portMappings = [
        {
          containerPort = 8080 ##### awsvpcによりHostPortはcontainerPortと同じになる
          hostPort      = 8080
          protocol      = "tcp"
          name          = "api-http" ##### ECSサービスのserviceのnameと一致させる
        }
      ]
      mountPoints    = []
      systemControls = []
      volumesFrom    = []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "ecs/${var.system_name}-${var.environment_name}-api-python-taskdef"
          "awslogs-region"        = var.region_name
          "awslogs-create-group"  = "true"
          ##### ログストリーム名（例：ecs/${container_name}/${ecs_task_id}）
          "awslogs-stream-prefix" = "ecs"
        }
      }
      secrets = [
        {
          name = "DB_APP_USERNAME"
          valueFrom = "${var.db_app_secret_arn}:username::"
        },
        {
          name = "DB_APP_PASSWORD"
          valueFrom = "${var.db_app_secret_arn}:password::"
        },
      ]
      environment = [
        {
          name = "DB_WRITER_HOST"
          value = "${var.db_writer_host}"
        },
        {
          name = "DB_READER_HOST"
          value = "${var.db_reader_host}"
        },
        {
          name = "DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name = "DB_NAME"
          value = "${var.db_name}"
        }
      ]
    }
  ])
  tags = {
    Name = "${var.system_name}-${var.environment_name}-api-python-taskdef"
  }
}

## ECSサービスの作成（APIサービス用）
resource "aws_ecs_service" "terra_ecs_service_api" {
  name                              = "${var.system_name}-${var.environment_name}-api-python-svc"
  cluster                           = aws_ecs_cluster.terra_ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.terra_ecs_task_definition_api.arn
  desired_count                     = var.api_desired_count
  force_new_deployment              = var.force_new_deployment
  capacity_provider_strategy { ##### launch_type属性と併用不可。記述なしの場合は、ECSクラスターのdefault_capacity_provider_strategyが適用される
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
  platform_version = var.platform_version
  enable_execute_command = var.enable_execute_command
  service_registries {
    registry_arn = aws_service_discovery_service.terra_service_discovery_service.arn
  }
  network_configuration {
    subnets          = var.ecs_protected_or_public_subnet_ids
    security_groups  = [var.api_security_group_id]
    assign_public_ip = var.create_protected_ngw_associations ? false : true ##### protected_ngw_associationsが、trueの時パブリックIPは割り当てない、falseの時パブリックIP割り当てる
  }
  deployment_circuit_breaker { ##### 新バージョンに切り替える際に、異常があれば元のバージョンにロールバックする機能
    enable   = var.deployment_circuit_breaker_enable
    rollback = var.deployment_circuit_breaker_rollback
  }
  deployment_controller { ##### デプロイ制御
    type = var.deployment_controller_type ##### ローリングデプロイかブルー/グリーンデプロイかを使用
  }
  lifecycle { ##### ダウンタイムゼロでデプロイするために必要
    create_before_destroy = true ##### 新バージョンのECSサービスを先に作成してから古いECSサービスを削除する
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-api-python-svc"
  }
}

## ECSタスク定義（Nginxリバースプロキシ用）
resource "aws_ecs_task_definition" "terra_ecs_task_definition_front" {
  family                   = "${var.system_name}-${var.environment_name}-front-nginx-taskdef"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.front_task_cpu
  memory                   = var.front_task_memory
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_task_execution_role_arn
  container_definitions = jsonencode([
    {
      name      = "front-nginx"
      image     = var.front_ecr_repository_url
      essential = true
      environment = [
        {
          name  = "SERVICE_DISCOVERY_NAME"
          value = "api-python"
        },
        {
          name  = "NAMESPACE_NAME"
          value = "${var.system_name}-${var.environment_name}-namespace"
        }
      ]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
          name          = "http-nginx"
        }
      ]
      mountPoints    = []
      systemControls = []
      volumesFrom    = []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "${var.system_name}-${var.environment_name}-front-nginx-taskdef"
          "awslogs-region"        = var.region_name
          "awslogs-create-group"  = "true"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  tags = {
    Name = "${var.system_name}-${var.environment_name}-front-nginx-taskdef"
  }
}

## ECSサービスの作成（Nginxリバースプロキシ用）
resource "aws_ecs_service" "terra_ecs_service_front" {
  name                              = "${var.system_name}-${var.environment_name}-front-nginx-svc"
  cluster                           = aws_ecs_cluster.terra_ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.terra_ecs_task_definition_front.arn
  desired_count                     = var.front_desired_count
  force_new_deployment              = var.force_new_deployment
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
  platform_version                  = "LATEST"
  enable_execute_command = true
  network_configuration {
    subnets          = var.ecs_protected_or_public_subnet_ids
    security_groups  = [var.front_security_group_id]
    assign_public_ip = var.create_protected_ngw_associations ? false : true
  }
  load_balancer { ##### ALBのターゲットグループと関連付け
    target_group_arn = var.front_target_group_arn
    container_name   = "front-nginx"
    container_port   = 80
  }
  health_check_grace_period_seconds = 60 ##### ヘルスチェックの猶予期間（秒）。新しいタスクが起動してから一定時間はヘルスチェックの結果を無視する
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-front-nginx-svc"
  }
} 

## ECSタスク定義（RDS（Aurora）データ投入用）
resource "aws_ecs_task_definition" "terra_ecs_task_definition_db_initdata" {
  family                   = "${var.system_name}-${var.environment_name}-db-initdata-taskdef"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.db_initdata_task_cpu
  memory                   = var.db_initdata_task_memory
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_task_execution_role_arn
  container_definitions = jsonencode([
    {
      name      = "db-initdata"
      image     = var.db_initdata_ecr_repository_url
      essential = true
      portMappings = [
        {
          containerPort = 3306
          protocol      = "tcp"
          name          = "db-initdata-http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "${var.system_name}-${var.environment_name}-db-initdata-taskdef"
          "awslogs-region"        = var.region_name
          "awslogs-create-group"  = "true"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      secrets = [
        {
          name = "DB_APP_USERNAME"
          valueFrom = "${var.db_app_secret_arn}:username::"
        },
        {
          name = "DB_APP_PASSWORD"
          valueFrom = "${var.db_app_secret_arn}:password::"
        },
      ]
      environment = [
        {
          name = "DB_WRITER_HOST"
          value = "${var.db_writer_host}"
        },
        {
          name = "DB_READER_HOST"
          value = "${var.db_reader_host}"
        },
        {
          name = "DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name = "DB_NAME"
          value = "${var.db_name}"
        },
      ]
    }
  ])
  tags = {
    Name = "${var.system_name}-${var.environment_name}-db-initdata-taskdef"
  }
}

## ECSタスク定義（RDS（Aurora）ユーザー作成用）
resource "aws_ecs_task_definition" "terra_ecs_task_definition_db_inituser" {
  family                   = "${var.system_name}-${var.environment_name}-db-inituser-taskdef"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.db_inituser_task_cpu
  memory                   = var.db_inituser_task_memory
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_task_execution_role_arn
  container_definitions = jsonencode([
    {
      name      = "db-inituser"
      image     = var.db_inituser_ecr_repository_url
      essential = true
      portMappings = [
        {
          containerPort = 3306
          protocol      = "tcp"
          name          = "db-inituser-http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "${var.system_name}-${var.environment_name}-db-inituser-taskdef"
          "awslogs-region"        = var.region_name
          "awslogs-create-group"  = "true"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      secrets = [
        {
          name = "DB_MASTER_USERNAME"
          valueFrom = "${var.db_master_secret_arn}:username::"
        },
        {
          name = "DB_MASTER_PASSWORD"
          valueFrom = "${var.db_master_secret_arn}:password::"
        },
        {
          name = "DB_APP_USER"
          valueFrom = "${var.db_app_secret_arn}:username::"
        },
        {
          name = "DB_APP_PASSWORD"
          valueFrom = "${var.db_app_secret_arn}:password::"
        },
      ]
      environment = [
        {
          name = "DB_WRITER_HOST"
          value = "${var.db_writer_host}"
        },
        {
          name = "DB_READER_HOST"
          value = "${var.db_reader_host}"
        },
        {
          name = "DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name = "DB_NAME"
          value = "${var.db_name}"
        },
      ]
    }
  ])
  tags = {
    Name = "${var.system_name}-${var.environment_name}-db-inituser-taskdef"
  }
}