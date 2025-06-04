# 柔軟NATゲートウェイ設定ガイド

本ドキュメントでは、環境とAZ数に応じてNATゲートウェイの数を柔軟に制御できるVPCモジュールの使用方法をご説明いたします。

## 🎯 概要

このVPCモジュールは、以下のように自動的にNATゲートウェイ数を決定します：

- **開発環境**: 最大1個（コスト最優先）
- **ステージング・本番環境**: AZ数に応じて2~3個
- **3AZ環境**: `use_all_azs_for_nat`で2個または3個を選択可能

## 📋 NATゲートウェイ数の自動決定ルール

### AZ 2つの場合（1aと1c）

| 環境 | protectedサブネット | NATゲートウェイ数 | 配置AZ |
|------|-------------------|------------------|--------|
| dev  | あり              | 1個              | 1a     |
| dev  | なし              | 0個              | -      |
| stg  | あり              | 2個              | 1a, 1c |
| stg  | なし              | 0個              | -      |
| prod | あり              | 2個              | 1a, 1c |
| prod | なし              | 0個              | -      |

### AZ 3つの場合（1a、1c、1d）

| 環境 | protectedサブネット | use_all_azs_for_nat | NATゲートウェイ数 | 配置AZ |
|------|-------------------|-------------------|------------------|--------|
| dev  | あり              | -                 | 1個              | 1a     |
| dev  | なし              | -                 | 0個              | -      |
| stg  | あり              | false（コスト重視）  | 2個              | 1a, 1c |
| stg  | あり              | true（パフォーマンス重視）| 3個          | 1a, 1c, 1d |
| stg  | なし              | -                 | 0個              | -      |
| prod | あり              | false（コスト重視）  | 2個              | 1a, 1c |
| prod | あり              | true（パフォーマンス重視）| 3個          | 1a, 1c, 1d |
| prod | なし              | -                 | 0個              | -      |

## 🔧 設定パラメータ

### 必須パラメータ

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  # 基本設定
  system_name      = "yourcompany"    # システム名
  environment_name = "dev"            # 環境名: dev, stg, prod
  vpc_cidr        = "10.0.0.0/16"    # VPCのCIDRブロック
  
  # サブネット設定
  subnet_list = [
    # サブネット定義...
  ]
  
  route_table_list = [
    # ルートテーブル定義...
  ]
}
```

### NATゲートウェイ制御パラメータ

```hcl
# 自動計算の有効/無効
enable_auto_nat_calculation = true  # true: 自動計算, false: 手動指定

# 3AZ環境での選択（stg/prod環境のみ有効）
use_all_azs_for_nat = false         # false: 2個（コスト重視）, true: 3個（パフォーマンス重視）

# 手動でNATゲートウェイ数を指定（自動計算無効時のみ）
nat_gateway_count = 2               # 0-3の値を指定

# protectedサブネットの作成有無
create_protected_ngw_associations = true

# その他の設定
map_public_ip_on_launch = false
```

## 📖 使用例

### 例1: 開発環境（自動計算）

```hcl
module "vpc_dev" {
  source = "./modules/vpc"
  
  system_name      = "mycompany"
  environment_name = "dev"
  
  enable_auto_nat_calculation = true
  create_protected_ngw_associations = true
  
  vpc_cidr = "10.0.0.0/16"
  map_public_ip_on_launch = false
  
  subnet_list = [
    { name = "1a", cidr_block = "10.0.1.0/24", type = "public" },
    { name = "1c", cidr_block = "10.0.2.0/24", type = "public" },
    { name = "1a", cidr_block = "10.0.11.0/24", type = "protected" },
    { name = "1c", cidr_block = "10.0.12.0/24", type = "protected" }
  ]
  
  route_table_list = [
    { name = "public", subnet = "1a", gateway_type = "internet_gateway" },
    { name = "public", subnet = "1c", gateway_type = "internet_gateway" },
    { name = "protected", subnet = "1a", gateway_type = "nat_gateway" },
    { name = "protected", subnet = "1c", gateway_type = "nat_gateway" }
  ]
}

# 結果: NATゲートウェイ 1個作成（1aのみ）
```

### 例2: 本番環境（3AZ、コスト重視）

```hcl
module "vpc_prod_cost" {
  source = "./modules/vpc"
  
  system_name      = "mycompany"
  environment_name = "prod"
  
  enable_auto_nat_calculation = true
  use_all_azs_for_nat = false  # コスト重視（2個）
  
  create_protected_ngw_associations = true
  
  vpc_cidr = "10.2.0.0/16"
  map_public_ip_on_launch = false
  
  subnet_list = [
    # 3つのAZ
    { name = "1a", cidr_block = "10.2.1.0/24", type = "public" },
    { name = "1c", cidr_block = "10.2.2.0/24", type = "public" },
    { name = "1d", cidr_block = "10.2.3.0/24", type = "public" },
    { name = "1a", cidr_block = "10.2.11.0/24", type = "protected" },
    { name = "1c", cidr_block = "10.2.12.0/24", type = "protected" },
    { name = "1d", cidr_block = "10.2.13.0/24", type = "protected" }
  ]
  
  route_table_list = [
    { name = "public", subnet = "1a", gateway_type = "internet_gateway" },
    { name = "public", subnet = "1c", gateway_type = "internet_gateway" },
    { name = "public", subnet = "1d", gateway_type = "internet_gateway" },
    { name = "protected", subnet = "1a", gateway_type = "nat_gateway" },
    { name = "protected", subnet = "1c", gateway_type = "nat_gateway" },
    { name = "protected", subnet = "1d", gateway_type = "nat_gateway" }
  ]
}

# 結果: NATゲートウェイ 2個作成（1a、1c）
```

### 例3: 本番環境（3AZ、パフォーマンス重視）

```hcl
module "vpc_prod_performance" {
  source = "./modules/vpc"
  
  system_name      = "mycompany"
  environment_name = "prod"
  
  enable_auto_nat_calculation = true
  use_all_azs_for_nat = true  # パフォーマンス重視（3個）
  
  create_protected_ngw_associations = true
  
  # 設定は例2と同じ...
}

# 結果: NATゲートウェイ 3個作成（1a、1c、1d）
```

### 例4: 手動でNATゲートウェイ数を指定

```hcl
module "vpc_manual" {
  source = "./modules/vpc"
  
  system_name      = "mycompany"
  environment_name = "prod"
  
  # 自動計算を無効にして手動指定
  enable_auto_nat_calculation = false
  nat_gateway_count = 1  # 明示的に1個を指定
  
  create_protected_ngw_associations = true
  
  # 他の設定...
}

# 結果: NATゲートウェイ 1個作成
```

## 📊 出力情報

モジュールは以下の有用な情報を出力します：

```hcl
# NATゲートウェイの数
output "nat_count" {
  value = module.vpc.nat_gateway_count
}

# 設定詳細情報
output "config_info" {
  value = module.vpc.nat_configuration_info
}

# NATゲートウェイの詳細情報
output "nat_details" {
  value = module.vpc.nat_gateway_details
}
```

出力例：
```json
{
  "nat_count": 2,
  "config_info": {
    "environment": "prod",
    "available_azs": 3,
    "has_protected_subnets": true,
    "use_all_azs_for_nat": false,
    "calculated_nat_count": 2,
    "final_nat_count": 2,
    "auto_calculation_enabled": true,
    "manual_override": false
  },
  "nat_details": {
    "1a": {
      "id": "nat-123456789abcdef01",
      "allocation_id": "eipalloc-123456789abcdef01",
      "public_ip": "52.196.1.1",
      "subnet_id": "subnet-123456789abcdef01",
      "availability_zone": "ap-northeast-1a"
    },
    "1c": {
      "id": "nat-987654321fedcba01",
      "allocation_id": "eipalloc-987654321fedcba01",
      "public_ip": "52.196.1.2",
      "subnet_id": "subnet-987654321fedcba01",
      "availability_zone": "ap-northeast-1c"
    }
  }
}
```

## 💰 コスト考慮事項

### NATゲートウェイのコスト

- **1個**: 約$32/月（最小コスト）
- **2個**: 約$64/月（可用性とコストのバランス）
- **3個**: 約$96/月（最高パフォーマンス）

### 推奨設定

| シナリオ | 推奨設定 | 理由 |
|----------|----------|------|
| 開発環境 | 自動計算（1個） | コスト最適化 |
| ステージング環境（2AZ） | 自動計算（2個） | 本番環境と同等の構成でテスト |
| ステージング環境（3AZ） | `use_all_azs_for_nat = false` | コストを抑えつつ可用性確保 |
| 本番環境（コスト重視） | `use_all_azs_for_nat = false` | 必要最小限の冗長化 |
| 本番環境（パフォーマンス重視） | `use_all_azs_for_nat = true` | 各AZで最適なパフォーマンス |

## 🔄 移行・変更手順

既存環境から新しい設定に移行する場合：

1. **現在の設定を確認**
   ```bash
   terraform plan
   ```

2. **段階的な変更**
   - 最初は`enable_auto_nat_calculation = false`で現状維持
   - 次に`enable_auto_nat_calculation = true`で自動計算に移行

3. **検証**
   ```bash
   terraform apply
   ```

## ⚠️ 注意事項

1. **protectedサブネットが存在しない場合**、NATゲートウェイは作成されません
2. **dev環境**では、設定に関係なく最大1個のNATゲートウェイのみ作成されます
3. **手動指定**（`nat_gateway_count`）は自動計算より優先されます
4. **NATゲートウェイの削除**は、関連するリソースの停止時間を伴う場合があります

## 🆘 トラブルシューティング

### よくある問題

1. **NATゲートウェイが作成されない**
   - `create_protected_ngw_associations = true`が設定されているか確認
   - protectedタイプのサブネットが定義されているか確認

2. **期待したNATゲートウェイ数と異なる**
   - `nat_configuration_info`の出力を確認
   - 自動計算のロジックを確認

3. **コストが予想より高い**
   - `nat_gateway_count`の出力を確認
   - `use_all_azs_for_nat`の設定を確認

### サポート

ご不明な点がございましたら、以下の情報と共にお問い合わせください：

- 使用中の設定ファイル
- `terraform plan`の出力
- `nat_configuration_info`の出力

---

**更新履歴**
- 2024年: 柔軟NATゲートウェイ設定機能を追加
- シンプルで直接的な制御方法を実装 