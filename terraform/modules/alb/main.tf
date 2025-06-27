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
  desync_mitigation_mode = var.desync_mitigation_mode
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
      bucket  = var.s3_alb_logs_bucket_name
      prefix  = "connectionlogs"
      enabled = true
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
  deregistration_delay = var.deregistration_delay ##### Connection draining time
  load_balancing_algorithm_type = var.load_balancing_algorithm_type ##### ラウンドロビン、最小未処理、重みづけのどれか
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
  routing_http_response_server_enabled = var.routing_http_response_server_enabled ##### curl等実行時にServerヘッダーを表示するかどうか
  ### 以下、ブラウザにhttp://urlで間違えてアクセスした場合やブラウザにhostnameだけを入力してアクセスした場合の対策
  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
      protocol    = "HTTPS"
      status_code = "HTTP_301" ##### HTTPから恒久的にHTTPSにリダイレクト（301: 恒久的なリダイレクト, 302: 一時的なリダイレクト）
    }
  }
  ### 以下、アプリケーションのセキュリティを強化するためのヘッダー各種
  routing_http_response_content_security_policy_header_value = "default-src 'self'" ##### XSS攻撃対策
  routing_http_response_x_content_type_options_header_value  = "nosniff" ##### MIME（マイム）タイプスニッフィング攻撃対策
  routing_http_response_x_frame_options_header_value         = "SAMEORIGIN" ##### クリックジャッキング攻撃対策
  tags = {
    Name = "${var.system_name}-${var.environment_name}-http-listener"
  }
}

## リスナー（HTTPS）の作成 (SSL証明書を使用、デフォルトはフロントエンドのターゲットグループに転送)
resource "aws_lb_listener" "terra_https_listener" {
  load_balancer_arn = aws_lb.terra_alb.arn
  port              = 443
  protocol          = "HTTPS"
  routing_http_response_server_enabled = var.routing_http_response_server_enabled ##### curl等実行時にServerヘッダーを表示するかどうか
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn
  ### 以下、ブラウザにhttps://IPAddressでアクセス（ポートスキャン）された場合の対策
  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/html"
      status_code = "403"
      message_body = <<-HTML
        <!DOCTYPE html>
        <html lang="ja">
        <head>
        <meta charset="UTF-8">
        <title>Access Denied</title>
        <style>
        body{font-family:sans-serif;background:#f5f7fa;margin:0;padding:20px;display:flex;justify-content:center;align-items:center;min-height:100vh}
        .container{background:#fff;padding:20px;border-radius:8px;box-shadow:0 2px 4px rgba(0,0,0,.1);text-align:center;max-width:400px;border-top:4px solid #e74c3c}
        h1{color:#c0392b;margin:10px 0}
        p{margin:15px 0;color:#2c3e50}
        .status{background:#f8f9fa;padding:8px 15px;border-radius:4px;color:#e74c3c;font-weight:bold;display:inline-block;border:1px solid #e9ecef}
        </style>
        </head>
        <body>
        <div class="container">
        <h1>Access Denied</h1>
        <p>Sorry, you are not allowed to access this page.</p>
        <div class="status">403 Forbidden</div>
        </div>
        </body>
        </html>
      HTML
    }
  }
  ### 以下、アプリケーションのセキュリティを強化するためのヘッダー各種
  routing_http_response_strict_transport_security_header_value = "max-age=31536000; includeSubDomains; preload" ##### HTTPへのダウングレード攻撃対策（常にHTTPSを使用）。中間者攻撃対策
  routing_http_response_content_security_policy_header_value = "default-src 'self'" ##### XSS攻撃対策
  routing_http_response_x_content_type_options_header_value  = "nosniff" ##### MIME（マイム）タイプスニッフィング攻撃対策
  routing_http_response_x_frame_options_header_value         = "SAMEORIGIN" ##### クリックジャッキング攻撃対策
  tags = {
    Name = "${var.system_name}-${var.environment_name}-https-listener"
  }
}

## リスナールール（HTTPS）の作成 (/maintenanceにアクセスした場合はメンテナンスページに転送)
resource "aws_lb_listener_rule" "terra_https_listener_rule1" {
  listener_arn = aws_lb_listener.terra_https_listener.arn
  priority = 10 ##### 数値が低いほど、ルールが優先
  condition {
    path_pattern {
      values = ["/maintenance"]
    }
  }
  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      status_code = "503"
      message_body = <<-HTML
        <!DOCTYPE html>
        <html lang="ja">
        <head>
        <meta charset="UTF-8">
        <title>Maintenance</title>
        <style>
        body{font-family:sans-serif;background:#e0f7fa;margin:0;padding:20px;display:flex;justify-content:center;align-items:center;min-height:100vh}
        .container{background:#fff;padding:20px;border-radius:8px;box-shadow:0 2px 4px rgba(0,0,0,.1);text-align:center;max-width:400px;border-top:4px solid #0288d1}
        h1{color:#0277bd;margin:10px 0}
        p{margin:15px 0;color:#01579b}
        .status{background:#e1f5fe;padding:8px 15px;border-radius:4px;color:#0288d1;font-weight:bold;display:inline-block;border:1px solid #b3e5fc}
        .progress{width:100%;height:4px;background:#e0f7fa;border-radius:2px;margin-top:20px}
        </style>
        </head>
        <body>
        <div class="container">
        <h1>Maintenance</h1>
        <p>We are currently performing maintenance on the system.<br>We apologize for the inconvenience.</p>
        <div class="status">503 Service Unavailable</div>
        <div class="progress"></div>
        </div>
        </body>
        </html>
      HTML
    }   
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-https-listener-rule1"
  }
}

## リスナールール（HTTPS）の作成 (/healthか/にアクセスした場合はフロントエンドのターゲットグループに転送)
resource "aws_lb_listener_rule" "terra_https_listener_rule2" {
  listener_arn = aws_lb_listener.terra_https_listener.arn
  priority = 100 ##### 数値が低いほど、ルールが優先
  condition {
    path_pattern {
      values = ["/health", "/"]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.terra_front_target_group.arn
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-https-listener-rule2"
  }
}

## リスナールール（HTTPS）の作成 (ブラウザに想定していないパスを入力した場合の対策)
resource "aws_lb_listener_rule" "terra_https_listener_rule3" {
  listener_arn = aws_lb_listener.terra_https_listener.arn
  priority = 1000 ##### 数値が低いほど、ルールが優先
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
  ### 以下、ブラウザに想定していないパスを入力した場合の対策
  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      status_code = "404"
      message_body = <<-HTML
        <!DOCTYPE html>
        <html lang="ja">
        <head>
        <meta charset="UTF-8">
        <title>404 Not Found</title>
        <style>
        body{font-family:sans-serif;background:#f5f7fa;margin:0;padding:20px;display:flex;justify-content:center;align-items:center;min-height:100vh}
        .container{background:#fff;padding:20px;border-radius:8px;box-shadow:0 2px 4px rgba(0,0,0,.1);text-align:center;max-width:400px;border-top:4px solid #e74c3c}
        h1{color:#c0392b;margin:10px 0}
        p{margin:15px 0;color:#2c3e50}
        .status{background:#f8f9fa;padding:8px 15px;border-radius:4px;color:#e74c3c;font-weight:bold;display:inline-block;border:1px solid #e9ecef}
        </style>
        </head>
        <body>
        <div class="container">
        <h1>404 Not Found</h1>
        <p>Sorry, the page you are looking for does not exist.</p>
        <div class="status">404 Not Found</div>
        </div>
        </body>
        </html>
      HTML
    }
  }
  tags = {
    Name = "${var.system_name}-${var.environment_name}-https-listener-rule3"
  }
}