# Aurora設定ガイド 🚀

## 🎯 実装完了内容

### ✅ Aurora自動計算機能
- **VPCモジュール連携**: サブネット数からAZ数を自動計算
- **環境別自動設定**: dev/stg/prod環境に最適化されたインスタンス数
- **柔軟な可用性戦略**: コスト重視 vs 可用性重視の選択

## 📋 設定パターン

### 1. **自動計算設定**（推奨）

```hcl
module "rds" {
  source = "../../modules/rds"
  
  # 基本設定のみ指定（インスタンス数は自動計算）
  cluster_instance_count = null  # 自動計算を使用
  use_all_azs_for_aurora = false # コスト重視（デフォルト）
  
  # その他の必要な変数...
}
```

### 2. **明示的設定**

```hcl
module "rds" {
  source = "../../modules/rds"
  
  # インスタンス数を明示的に指定
  cluster_instance_count = 2      # 2台固定
  use_all_azs_for_aurora = true   # 使用されない（明示指定時）
  
  # その他の必要な変数...
}
```

## 🏗️ 環境別推奨設定

### 🔧 Dev環境
**目的**: 開発・テスト用（コスト最優先）

```hcl
# 設定
cluster_instance_count = null    # 自動計算（1台）
use_all_azs_for_aurora = false   # 使用されない

# 結果
# インスタンス数: 1台
# 配置AZ: 1a
# 月額コスト: ~$50（db.t4g.medium想定）
```

### 🔄 Stg環境
**目的**: 本番前検証（コスト効率重視）

```hcl
# 設定（2AZ環境）
cluster_instance_count = null    # 自動計算（2台）
use_all_azs_for_aurora = false   # コスト重視

# 結果
# インスタンス数: 2台
# 配置AZ: 1a + 1c
# 月額コスト: ~$100（db.t4g.medium想定）
```

```hcl
# 設定（3AZ環境 - コスト重視）
cluster_instance_count = null    # 自動計算（2台）
use_all_azs_for_aurora = false   # コスト重視

# 結果
# インスタンス数: 2台
# 配置AZ: 1a + 1c
# 月額コスト: ~$100（db.t4g.medium想定）
```

### 🚀 Prod環境
**目的**: 本番運用

#### パターン1: コスト効率重視
```hcl
# 設定（3AZ環境）
cluster_instance_count = null    # 自動計算（2台）
use_all_azs_for_aurora = false   # コスト重視

# 結果
# インスタンス数: 2台（1 writer + 1 reader）
# 配置AZ: 1a + 1c
# 月額コスト: ~$300（db.r6g.large想定）
# 可用性: 99.95%
```

#### パターン2: 高可用性重視
```hcl
# 設定（3AZ環境）
cluster_instance_count = null    # 自動計算（3台）
use_all_azs_for_aurora = true    # 可用性重視

# 結果
# インスタンス数: 3台（1 writer + 2 readers）
# 配置AZ: 1a + 1c + 1d
# 月額コスト: ~$450（db.r6g.large想定）
# 可用性: 99.99%
```

## 💰 コスト比較表

| 環境 | AZ数 | 戦略 | インスタンス数 | 配置AZ | 月額コスト* | 可用性 |
|------|------|------|----------------|--------|-------------|--------|
| dev | 2AZ | 自動 | 1台 | 1a | ~$50 | 99.9% |
| stg | 2AZ | 自動 | 2台 | 1a+1c | ~$100 | 99.95% |
| stg | 3AZ | コスト重視 | 2台 | 1a+1c | ~$100 | 99.95% |
| stg | 3AZ | 可用性重視 | 3台 | 1a+1c+1d | ~$150 | 99.99% |
| prod | 2AZ | 自動 | 2台 | 1a+1c | ~$300 | 99.95% |
| prod | 3AZ | コスト重視 | 2台 | 1a+1c | ~$300 | 99.95% |
| prod | 3AZ | 可用性重視 | 3台 | 1a+1c+1d | ~$450 | 99.99% |

*db.t4g.medium(dev/stg)、db.r6g.large(prod)想定

## 🔧 使用例

### 例1: Dev環境（基本設定）
```hcl
module "rds" {
  source                            = "../../modules/rds"
  region_name                       = var.region_name
  system_name                       = var.system_name
  environment_name                  = "dev"
  
  # VPC設定（自動取得）
  private_subnet_ids                = values(module.vpc.vpc_private_subnet_ids)
  available_azs_count               = module.vpc.vpc_available_azs_count
  available_azs_names               = module.vpc.vpc_available_azs_names
  
  # Aurora設定（自動計算）
  cluster_instance_count            = null   # 自動: 1台
  use_all_azs_for_aurora           = false  # 使用されない
  
  # その他の設定...
  instance_class                    = "db.t4g.medium"
  # ...
}
```

### 例2: Prod環境（高可用性）
```hcl
module "rds" {
  source                            = "../../modules/rds"
  region_name                       = var.region_name
  system_name                       = var.system_name
  environment_name                  = "prod"
  
  # VPC設定（自動取得）
  private_subnet_ids                = values(module.vpc.vpc_private_subnet_ids)
  available_azs_count               = module.vpc.vpc_available_azs_count
  available_azs_names               = module.vpc.vpc_available_azs_names
  
  # Aurora設定（高可用性重視）
  cluster_instance_count            = null  # 自動: 3台（3AZ時）
  use_all_azs_for_aurora           = true   # 可用性重視
  
  # その他の設定...
  instance_class                    = "db.r6g.large"
  deletion_protection               = true
  # ...
}
```

### 例3: 特殊要件（明示指定）
```hcl
module "rds" {
  source                            = "../../modules/rds"
  
  # Aurora設定（明示指定）
  cluster_instance_count            = 2     # 環境に関係なく2台固定
  use_all_azs_for_aurora           = false # 明示指定時は使用されない
  
  # その他の設定...
}
```

## 🎛️ 設定変数

### 主要変数

| 変数名 | 説明 | デフォルト | 例 |
|--------|------|------------|-----|
| `cluster_instance_count` | インスタンス数の明示指定（nullで自動計算） | `null` | `2` |
| `use_all_azs_for_aurora` | 3AZ環境での配置戦略 | `false` | `true` |

### 自動計算ロジック

```hcl
# 環境別インスタンス数
dev  = 1台                    # 常に1台（1a）
stg  = 2台 or 3台（設定による） # 2AZ時:2台、3AZ時:設定による
prod = 2台 or 3台（設定による） # 2AZ時:2台、3AZ時:設定による

# 3AZ環境での台数決定
use_all_azs_for_aurora = false → 2台（コスト重視）
use_all_azs_for_aurora = true  → 3台（可用性重視）
```

## 🚨 トラブルシューティング

### 問題1: インスタンス数が期待と違う
```bash
# 確認コマンド
terraform output rds_cluster_instance_details

# よくある原因
1. cluster_instance_count が明示指定されている
2. use_all_azs_for_aurora の設定が意図と違う
3. VPCのAZ数が期待と違う
```

### 問題2: AZ配置が意図と違う
```bash
# 確認コマンド
terraform output vpc_available_azs_names
terraform output rds_cluster_instance_details

# 対策
1. VPCモジュールのsubnet_listを確認
2. AZ名が正しく設定されているか確認
```

### 問題3: コストが予算を超過
```bash
# 対策
1. use_all_azs_for_aurora = false に設定（コスト重視）
2. instance_class を小さいサイズに変更
3. dev環境では必ず1台になることを確認
```

## 📊 出力情報

```hcl
# 利用可能な出力値
output "cluster_details" {
  value = {
    id                = module.rds.rds_cluster_id
    writer_endpoint   = module.rds.rds_cluster_writer_endpoint
    reader_endpoint   = module.rds.rds_cluster_reader_endpoint
    instance_details  = module.rds.rds_cluster_instance_details
  }
}
```

## 🎉 まとめ

この設定により以下が実現されます：

✅ **自動最適化**: 環境とAZ数に応じた最適なインスタンス数  
✅ **コスト効率**: デフォルトでコスト重視の設定  
✅ **高可用性オプション**: 必要に応じて可用性重視に切り替え可能  
✅ **明示制御**: 特殊要件時は明示的な制御も可能  
✅ **運用しやすさ**: 分かりやすい設定例とトラブルシューティング

**チームの他のメンバーも設定を理解しやすく、運用時の判断もしやすい構成になりました！** 🚀 