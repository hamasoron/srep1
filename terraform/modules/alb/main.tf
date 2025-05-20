# リソースの定義
## ALBの作成
resource "aws_lb" "terra_alb" {
  name               = "${var.system_name}-${var.environment_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2 = true
  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.s3_alb_logs_bucket_name
      prefix  = "accesslogs"
      enabled = true
    }
  }
  dynamic "connection_logs" {
    for_each = var.enable_connection_logs ? [1] : []
    content {
      enabled = true
      bucket  = var.s3_alb_logs_bucket_name
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
  load_balancing_algorithm_type = var.load_balancing_algorithm_type
  health_check {
    enabled             = true
    interval            = var.health_check_interval
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    matcher             = var.health_check_matcher
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-front-nginx-tg"
  }
}

## リスナー（HTTP）の作成 (デフォルトはフロントエンドのターゲットグループに転送)
resource "aws_lb_listener" "terra_http_listener" {
  load_balancer_arn = aws_lb.terra_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terra_front_target_group.arn
  }
}

## リスナー（HTTPS）の作成 (SSL証明書を使用、デフォルトはフロントエンドのターゲットグループに転送)
resource "aws_lb_listener" "terra_https_listener" {
  load_balancer_arn = aws_lb.terra_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terra_front_target_group.arn
  }
}