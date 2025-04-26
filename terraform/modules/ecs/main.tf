# リソースの定義
## ECSクラスターの作成
resource "aws_ecs_cluster" "terra_ecs_cluster" {
  name = "${var.system_name}-${var.environment_name}-cluster"
  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.service_connect_namespace.arn
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-cluster"
  }
}

## ECSクラスターの容量プロバイダー
resource "aws_ecs_cluster_capacity_providers" "terra_ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.terra_ecs_cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

## Service Connect用のHTTP名前空間
resource "aws_service_discovery_http_namespace" "service_connect_namespace" {
  name        = "${var.system_name}-${var.environment_name}-cluster"
  description = "Service Connect namespace for ${var.system_name} ${var.environment_name}"
  tags = {
    Name = "${var.system_name}-${var.environment_name}-cluster-namespace"
  }
}

## ECSタスク定義（APIサービス用）
resource "aws_ecs_task_definition" "terra_ecs_task_definition_api" {
  family                   = "${var.system_name}-${var.environment_name}-api-python-taskdef"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.api_task_cpu
  memory                   = var.api_task_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  container_definitions = jsonencode([
    {
      name      = "api-python"
      image     = "public.ecr.aws/nginx/nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          name          = "api-http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.system_name}-${var.environment_name}-api-python-taskdef"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name  = "ENV"
          value = var.environment_name
        }
      ]
    }
  ])
  tags = {
    Name = "${var.system_name}-${var.environment_name}-api-python-taskdef"
  }
}

## CloudWatch Logsグループの作成
resource "aws_cloudwatch_log_group" "terra_cloudwatch_log_group_api" {
  name              = "/ecs/${var.system_name}-${var.environment_name}-api-python-taskdef"
  retention_in_days = var.log_retention_days
  tags = {
    Name = "${var.system_name}-${var.environment_name}-api-python-taskdef-logs"
  }
}

## ECSサービスの作成
resource "aws_ecs_service" "terra_ecs_service_api" {
  name                              = "${var.system_name}-${var.environment_name}-api-python-svc"
  cluster                           = aws_ecs_cluster.terra_ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.terra_ecs_task_definition_api.arn
  desired_count                     = var.api_desired_count
  launch_type                       = "FARGATE"
  platform_version                  = "LATEST"
  health_check_grace_period_seconds = 60
  network_configuration {
    subnets          = var.create_protected_ngw_associations ? var.protected_subnet_ids : var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = var.create_protected_ngw_associations ? false : true
  }
  # Service Connect設定のみ使用
  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.service_connect_namespace.arn
    # APIサービスをプロバイダーとして登録
    service {
      port_name      = "api-http"  # タスク定義のportMappingsのnameと一致させる
      discovery_name = "api-python"  # サービスディスカバリー名
      
      client_alias {
        port     = 8080
        dns_name = "api-python"  # この名前でサービスディスカバリーできる
      }
    }
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }
  # 設定変更時に新しいサービスを先に作成してから古いサービスを削除する
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-api-python-svc"
  }
}

## リバースプロキシ用のタスク定義（Nginx）
resource "aws_ecs_task_definition" "terra_ecs_task_definition_front" {
  family                   = "${var.system_name}-${var.environment_name}-front-nginx-taskdef"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.front_task_cpu
  memory                   = var.front_task_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  container_definitions = jsonencode([
    {
      name      = "front-nginx"
      image     = "public.ecr.aws/nginx/nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
          name          = "http-nginx"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.system_name}-${var.environment_name}-front-nginx-taskdef"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name  = "ENV"
          value = var.environment_name
        },
        {
          name  = "API_SERVICE_HOST"
          value = "api-python"
        },
        {
          name  = "API_SERVICE_PORT"
          value = "8080"
        }
      ]
    }
  ])
  tags = {
    Name = "${var.system_name}-${var.environment_name}-front-nginx-taskdef"
  }
}

## CloudWatch Logsグループの作成（フロントエンド用）
resource "aws_cloudwatch_log_group" "terra_cloudwatch_log_group_front" {
  name              = "/ecs/${var.system_name}-${var.environment_name}-front-nginx-taskdef"
  retention_in_days = var.log_retention_days
  tags = {
    Name = "${var.system_name}-${var.environment_name}-front-nginx-taskdef-logs"
  }
}

## ECSサービスの作成（Nginxリバースプロキシ用）
resource "aws_ecs_service" "terra_ecs_service_front" {
  name                              = "${var.system_name}-${var.environment_name}-front-nginx-svc"
  cluster                           = aws_ecs_cluster.terra_ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.terra_ecs_task_definition_front.arn
  desired_count                     = var.front_desired_count
  launch_type                       = "FARGATE"
  platform_version                  = "LATEST"
  health_check_grace_period_seconds = 60
  
  network_configuration {
    subnets          = var.create_protected_ngw_associations ? var.protected_subnet_ids : var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = var.create_protected_ngw_associations ? false : true
  }
  
  # ALBのターゲットグループと関連付け
  load_balancer {
    target_group_arn = var.front_target_group_arn
    container_name   = "front-nginx"
    container_port   = 80
  }
  
  # Service Connect設定（クライアント側のみ）
  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.service_connect_namespace.arn
  }
  
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }
  # 設定変更時に新しいサービスを先に作成してから古いサービスを削除する
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-front-nginx-svc"
  }
} 