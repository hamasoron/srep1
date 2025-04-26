# リソースの定義
## ALBの作成
resource "aws_lb" "terra_alb" {
  name               = "${var.system_name}-${var.environment_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = "${var.system_name}-${var.environment_name}-alb-logs"
      prefix  = "accesslogs"
      enabled = true
    }
  }
  dynamic "connection_logs" {
    for_each = var.enable_connection_logs ? [1] : []
    content {
      enabled = true
      bucket  = "${var.system_name}-${var.environment_name}-alb-logs"
      prefix  = "connectionlogs"
    }
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-alb"
  }
}

## ターゲットグループ（front）の作成
resource "aws_lb_target_group" "terra_front_target_group" {
  name        = "${var.system_name}-${var.environment_name}-front-nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  deregistration_delay = var.deregistration_delay
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-front-nginx-tg"
  }
}

## HTTPリスナーの作成 (デフォルトはフロントエンド)
resource "aws_lb_listener" "terra_http_listener" {
  load_balancer_arn = aws_lb.terra_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terra_front_target_group.arn
  }
}