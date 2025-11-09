# Security Group モジュール

このモジュールはAWS Security Groupを動的に作成し、cidr_blocksやSecurity Group間の参照ルールを宣言的に定義できます。

## 機能

- **cidr_blocks**ベースのingressルール（従来通り）
- **security_groups**ベースのingressルール（新機能）
- 動的egress rule作成

## 使用方法

### 基本的な使用例

```hcl
sg_definitions = {
  "alb" = {
    description = "ALB Security Group"
    ingress = [
      { 
        from_port = 80, 
        to_port = 80, 
        protocol = "tcp", 
        cidr_blocks = ["0.0.0.0/0"],
        description = "HTTP from internet"
      },
      { 
        from_port = 443, 
        to_port = 443, 
        protocol = "tcp", 
        cidr_blocks = ["0.0.0.0/0"],
        description = "HTTPS from internet"
      }
    ]
    egress = [
      { 
        from_port = 0, 
        to_port = 0, 
        protocol = "-1", 
        cidr_blocks = ["0.0.0.0/0"],
        description = "All outbound traffic"
      }
    ]
  }
  
  "ecs-front-nginx" = {
    description = "ECS Frontend Nginx Security Group"
    ingress = [
      { 
        from_port = 80, 
        to_port = 80, 
        protocol = "tcp", 
        security_groups = ["alb"],
        description = "HTTP from ALB"
      }
    ]
    egress = [
      { 
        from_port = 0, 
        to_port = 0, 
        protocol = "-1", 
        cidr_blocks = ["0.0.0.0/0"],
        description = "All outbound traffic"
      }
    ]
  }
  
  "ecs-api-python" = {
    description = "ECS API Python Security Group"
    ingress = [
      { 
        from_port = 8080, 
        to_port = 8080, 
        protocol = "tcp", 
        security_groups = ["ecs-front-nginx"],
        description = "API access from frontend"
      }
    ]
    egress = [
      { 
        from_port = 0, 
        to_port = 0, 
        protocol = "-1", 
        cidr_blocks = ["0.0.0.0/0"],
        description = "All outbound traffic"
      }
    ]
  }
  
  "rds" = {
    description = "RDS Security Group"
    ingress = [
      { 
        from_port = 3306, 
        to_port = 3306, 
        protocol = "tcp", 
        security_groups = ["ecs-api-python", "lambda", "cloudshell"],
        description = "MySQL access from application services"
      }
    ]
    egress = [
      { 
        from_port = 0, 
        to_port = 0, 
        protocol = "-1", 
        cidr_blocks = ["0.0.0.0/0"],
        description = "All outbound traffic"
      }
    ]
  }
}
```

### フィールド説明

#### ingress ルール
- `from_port`: 開始ポート番号
- `to_port`: 終了ポート番号
- `protocol`: プロトコル (tcp, udp, icmp, -1など)
- `cidr_blocks`: CIDR ブロックのリスト（任意）
- `security_groups`: 参照するSecurity Groupのキー名のリスト（任意）
- `description`: ルールの説明（任意）

**注意**: `cidr_blocks`と`security_groups`のどちらか一方を指定してください。両方指定した場合、両方のルールが作成されます。

#### egress ルール
- `from_port`: 開始ポート番号
- `to_port`: 終了ポート番号
- `protocol`: プロトコル
- `cidr_blocks`: CIDR ブロックのリスト（必須）
- `description`: ルールの説明（任意）

## 移行について

従来の個別`aws_security_group_rule`リソースから新しい宣言的な定義に移行する際は：

1. 既存の`sg_definitions`で`security_groups`フィールドを使用するようにterraform.tfvarsを更新
2. `terraform plan`で変更内容を確認
3. `terraform apply`で適用

個別の`aws_security_group_rule`リソースは削除されるので、state管理に注意してください。 