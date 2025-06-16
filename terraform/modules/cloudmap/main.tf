# リソースの定義
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
    routing_policy = "MULTIVALUE" ##### 複数のタスクが存在する場合、それらのタスクのIPアドレスを返す（ラウンドロビン方式）。MULTIVALUE: 複数値（multi + value））
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