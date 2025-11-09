# NAT Gateway 仕様書

## 📋 概要

本モジュールでは、`create_protected_ngw_associations`と`nat_gateway_list`の設定に基づいて、NATゲートウェイの作成とprotectedサブネットのルーティングを柔軟に制御できます。

## 🔧 設定パラメータ

### `create_protected_ngw_associations`
- **型**: `bool`
- **説明**: protectedサブネットとNATゲートウェイの関連付けを作成するかどうかを制御
- **デフォルト値**: なし（必須設定）

### `nat_gateway_list`
- **型**: `list(object({ az = string, enabled = bool }))`
- **説明**: 各AZでのNATゲートウェイの有効/無効を明示的に指定
- **対応AZ**: `["1a", "1c", "1d"]`

## 📖 動作仕様

### 🚫 `create_protected_ngw_associations = false` の場合

| 環境 | NATゲートウェイ数 | 動作 |
|------|------------------|------|
| 2AZ | 0個 | NATゲートウェイは作成されません |
| 3AZ | 0個 | NATゲートウェイは作成されません |

**注意**: この設定の場合、`subnet_list`にprotectedタイプのサブネットが存在してはいけません。

---

### ✅ `create_protected_ngw_associations = true` の場合

#### 🏢 2AZ環境の仕様

| NATゲートウェイ数 | ルーティング仕様 | 説明 |
|------------------|------------------|------|
| **1個** | 🌐 全てのprotectedサブネット → 1aのNATゲートウェイ | コスト重視の構成 |
| **2個** | 🔄 各protectedサブネット → 同じAZ内のNATゲートウェイ | 高可用性構成 |

**詳細ルーティング（2AZ）:**
```
NATゲートウェイ1個の場合:
├── protected-subnet-1a → NAT Gateway 1a
└── protected-subnet-1c → NAT Gateway 1a

NATゲートウェイ2個の場合:
├── protected-subnet-1a → NAT Gateway 1a
└── protected-subnet-1c → NAT Gateway 1c
```

#### 🏗️ 3AZ環境の仕様

| NATゲートウェイ数 | ルーティング仕様 | 説明 |
|------------------|------------------|------|
| **1個** | 🌐 全てのprotectedサブネット → 1aのNATゲートウェイ | 最小構成 |
| **2個** | 🔄 1a → 1a、1c・1d → 1c のNATゲートウェイ | バランス構成 |
| **3個** | 🎯 各protectedサブネット → 同じAZ内のNATゲートウェイ | 最高性能構成 |

**詳細ルーティング（3AZ）:**
```
NATゲートウェイ1個の場合:
├── protected-subnet-1a → NAT Gateway 1a
├── protected-subnet-1c → NAT Gateway 1a
└── protected-subnet-1d → NAT Gateway 1a

NATゲートウェイ2個の場合:
├── protected-subnet-1a → NAT Gateway 1a
├── protected-subnet-1c → NAT Gateway 1c
└── protected-subnet-1d → NAT Gateway 1c

NATゲートウェイ3個の場合:
├── protected-subnet-1a → NAT Gateway 1a
├── protected-subnet-1c → NAT Gateway 1c
└── protected-subnet-1d → NAT Gateway 1d
```

## 🔧 設定例

### 例1: 2AZ環境 - NATゲートウェイ1個

```hcl
create_protected_ngw_associations = true

nat_gateway_list = [
  { az = "1a", enabled = true },
  { az = "1c", enabled = false }
]

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
```

**結果**: 1aにNATゲートウェイ1個作成、1aと1cの両方のprotectedサブネットが1aのNATゲートウェイを経由

### 例2: 3AZ環境 - NATゲートウェイ2個

```hcl
create_protected_ngw_associations = true

nat_gateway_list = [
  { az = "1a", enabled = true },
  { az = "1c", enabled = true },
  { az = "1d", enabled = false }
]

subnet_list = [
  { name = "1a", cidr_block = "10.0.1.0/24", type = "public" },
  { name = "1c", cidr_block = "10.0.2.0/24", type = "public" },
  { name = "1d", cidr_block = "10.0.3.0/24", type = "public" },
  { name = "1a", cidr_block = "10.0.11.0/24", type = "protected" },
  { name = "1c", cidr_block = "10.0.12.0/24", type = "protected" },
  { name = "1d", cidr_block = "10.0.13.0/24", type = "protected" }
]

route_table_list = [
  { name = "public", subnet = "1a", gateway_type = "internet_gateway" },
  { name = "public", subnet = "1c", gateway_type = "internet_gateway" },
  { name = "public", subnet = "1d", gateway_type = "internet_gateway" },
  { name = "protected", subnet = "1a", gateway_type = "nat_gateway" },
  { name = "protected", subnet = "1c", gateway_type = "nat_gateway" },
  { name = "protected", subnet = "1d", gateway_type = "nat_gateway" }
]
```

**結果**: 1aと1cにNATゲートウェイ2個作成、1a→1a、1c・1d→1cのNATゲートウェイを経由

### 例3: NATゲートウェイ無効化

```hcl
create_protected_ngw_associations = false

nat_gateway_list = [
  { az = "1a", enabled = false },
  { az = "1c", enabled = false }
]

subnet_list = [
  { name = "1a", cidr_block = "10.0.1.0/24", type = "public" },
  { name = "1c", cidr_block = "10.0.2.0/24", type = "public" },
  { name = "1a", cidr_block = "10.0.21.0/24", type = "private" },
  { name = "1c", cidr_block = "10.0.22.0/24", type = "private" }
]

route_table_list = [
  { name = "public", subnet = "1a", gateway_type = "internet_gateway" },
  { name = "public", subnet = "1c", gateway_type = "internet_gateway" },
  { name = "private", subnet = "1a", gateway_type = "none" },
  { name = "private", subnet = "1c", gateway_type = "none" }
]
```

**結果**: NATゲートウェイは作成されず、protectedサブネットも作成されません

## 💡 コスト最適化のガイドライン

| 環境タイプ | 推奨構成 | 理由 |
|------------|----------|------|
| **開発環境** | NATゲートウェイ1個 | コスト重視 |
| **ステージング環境** | NATゲートウェイ1-2個 | 本番環境のテスト |
| **本番環境（コスト重視）** | NATゲートウェイ2個 | 冗長性とコストのバランス |
| **本番環境（性能重視）** | 全AZにNATゲートウェイ | 最高のパフォーマンス |

## ⚠️ 注意事項

1. **`create_protected_ngw_associations = false`** の場合
   - protectedタイプのサブネットは作成できません
   - NATゲートウェイも作成されません

2. **NATゲートウェイの作成場所**
   - NATゲートウェイは必ずpublicサブネットに作成されます
   - 対応するpublicサブネットが存在しない場合はエラーになります

3. **料金について**
   - NATゲートウェイは時間単位で課金されます
   - データ転送量に応じた従量課金もあります

4. **変更時の注意**
   - NATゲートウェイの削除は、関連するリソースの停止時間を伴います
   - 本番環境での変更は慎重に行ってください

## 🆘 トラブルシューティング

### よくある問題と解決方法

#### 1. NATゲートウェイが作成されない
**原因**: 
- `create_protected_ngw_associations = false`に設定されている
- `nat_gateway_list`で全てのNATゲートウェイが`enabled = false`になっている

**解決方法**:
```hcl
create_protected_ngw_associations = true
nat_gateway_list = [
  { az = "1a", enabled = true }  # 少なくとも1つをtrueに設定
]
```

#### 2. protectedサブネットが作成されない
**原因**: `create_protected_ngw_associations = false`の場合

**解決方法**: `create_protected_ngw_associations = true`に変更

#### 3. ルーティングが期待通りに動作しない
**確認ポイント**:
- `route_table_list`の`gateway_type`が正しく設定されているか
- protectedサブネットに対応するNATゲートウェイが有効になっているか

## 📊 リソース作成マトリックス

| 設定 | 2AZ-NAT1個 | 2AZ-NAT2個 | 3AZ-NAT1個 | 3AZ-NAT2個 | 3AZ-NAT3個 |
|------|------------|------------|------------|------------|------------|
| **NATゲートウェイ** | 1個 | 2個 | 1個 | 2個 | 3個 |
| **EIP** | 1個 | 2個 | 1個 | 2個 | 3個 |
| **ルートテーブル** | protectedサブネット数に応じる | protectedサブネット数に応じる | protectedサブネット数に応じる | protectedサブネット数に応じる | protectedサブネット数に応じる |
| **月額コスト概算** | ~$45 | ~$90 | ~$45 | ~$90 | ~$135 |

*コストは東京リージョンの概算値です（データ転送料は除く）

---

このドキュメントは、VPCモジュールのNATゲートウェイ仕様の完全なガイドです。不明な点がありましたら、お気軽にお問い合わせください。 