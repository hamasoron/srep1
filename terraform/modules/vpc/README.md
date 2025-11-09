# VPCモジュール

## 概要
このモジュールは、AWS VPCとその関連リソース（サブネット、ルートテーブル、NATゲートウェイなど）を作成します。

## 設定バリデーション

### 実装済みエラーハンドリング

terraform.tfvarsの設定矛盾を防ぐため、以下のバリデーションを実装しています：

#### 1. Protectedサブネット設定の整合性
```hcl
# エラー例：create_protected_ngw_associations = false なのに protected サブネットが存在
create_protected_ngw_associations = false
subnet_list = [
  { name = "1a", cidr_block = "10.0.67.0/24", type = "protected" }  # ❌ エラー
]
```
**エラーメッセージ**: "Protected subnets cannot exist when create_protected_ngw_associations is false."

#### 2. ProtectedサブネットとNATゲートウェイの依存関係
```hcl
# エラー例：protected サブネットがあるのに NAT Gateway が無効
subnet_list = [
  { name = "1a", cidr_block = "10.0.67.0/24", type = "protected" }
]
nat_gateway_list = [
  { az = "1a", enabled = false }  # ❌ エラー
]
```
**エラーメッセージ**: "When protected subnets exist, at least one NAT gateway must be enabled."

#### 3. Private/ProtectedサブネットとNATゲートウェイの依存関係
```hcl
# エラー例：private/protected サブネットがあるのに NAT Gateway が全て無効
create_protected_ngw_associations = true
subnet_list = [
  { name = "1a", cidr_block = "10.0.70.0/24", type = "private" }
]
nat_gateway_list = [
  { az = "1a", enabled = false }  # ❌ エラー
]
```
**エラーメッセージ**: "When private or protected subnets exist and create_protected_ngw_associations is true, at least one NAT gateway must be enabled."

#### 4. Route TableとSubnetの対応関係
```hcl
# エラー例：存在しないサブネットを参照するルートテーブル
subnet_list = [
  { name = "1a", cidr_block = "10.0.64.0/24", type = "public" }
]
route_table_list = [
  { name = "public", subnet = "1c", gateway_type = "internet_gateway" }  # ❌ 1c サブネットが存在しない
]
```
**エラーメッセージ**: "Each route_table entry must correspond to an existing subnet with matching name and type."

#### 5. ProtectedルートテーブルとNATゲートウェイの整合性
```hcl
# エラー例：protected ルートテーブルで nat_gateway を指定しているが、対応する NAT Gateway が無効
route_table_list = [
  { name = "protected", subnet = "1a", gateway_type = "nat_gateway" }
]
nat_gateway_list = [
  { az = "1a", enabled = false }  # ❌ エラー
]
```
**エラーメッセージ**: "Protected route tables with nat_gateway type require corresponding NAT gateway to be enabled."

#### 6. Gateway TypeとSubnet Typeの整合性
```hcl
# エラー例：public サブネットなのに none を指定
route_table_list = [
  { name = "public", subnet = "1a", gateway_type = "none" }  # ❌ public は internet_gateway であるべき
]
```
**エラーメッセージ**: "Route table gateway_type must match the subnet type: public->internet_gateway, private->none, protected->nat_gateway or none."

## 使用方法

### 正常な設定例
```hcl
create_protected_ngw_associations = true
vpc_cidr = "10.0.64.0/19"
nat_gateway_list = [
  { az = "1a", enabled = true },
  { az = "1c", enabled = false },
]
subnet_list = [
  { name = "1a", cidr_block = "10.0.64.0/24", type = "public" },
  { name = "1a", cidr_block = "10.0.67.0/24", type = "protected" },
  { name = "1a", cidr_block = "10.0.70.0/24", type = "private" },
]
route_table_list = [
  { name = "public", subnet = "1a", gateway_type = "internet_gateway" },
  { name = "protected", subnet = "1a", gateway_type = "nat_gateway" },
  { name = "private", subnet = "1a", gateway_type = "none" },
]
``` 