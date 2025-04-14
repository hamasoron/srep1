# ALBの作成
resource "aws_lb" "terra_alb" {
  name               = "${var.system_name}-${var.environment_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Name = "${var.system_name}-${var.environment_name}-alb"
  }
}

# APIサービス用ターゲットグループの作成
resource "aws_lb_target_group" "terra_api_target_group" {
  name        = "${var.system_name}-${var.environment_name}-api-python-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "${var.system_name}-${var.environment_name}-api-python-tg"
  }
}

# フロントエンド用ターゲットグループの作成
resource "aws_lb_target_group" "terra_front_target_group" {
  name        = "${var.system_name}-${var.environment_name}-front-nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

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

# HTTPリスナーの作成 (デフォルトはフロントエンド)
resource "aws_lb_listener" "terra_http_listener" {
  load_balancer_arn = aws_lb.terra_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terra_front_target_group.arn
  }
}

# API用のリスナールール
# APIリクエストも含めてすべてNginxに転送するため、このルールは削除
# resource "aws_lb_listener_rule" "terra_api_rule" {
#   listener_arn = aws_lb_listener.terra_http_listener.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.terra_api_target_group.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/api/*"]
#     }
#   }
# }

# HTTPSリスナーの作成（SSL証明書が利用可能な場合）
resource "aws_lb_listener" "terra_https_listener" {
  count             = var.enable_https ? 1 : 0
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

# HTTPS API用のリスナールール
# APIリクエストも含めてすべてNginxに転送するため、このルールは削除
# resource "aws_lb_listener_rule" "terra_https_api_rule" {
#   count        = var.enable_https ? 1 : 0
#   listener_arn = aws_lb_listener.terra_https_listener[0].arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.terra_api_target_group.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/api/*"]
#     }
#   }
# } 