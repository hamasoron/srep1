# RDS Aurora Module

このモジュールは、AWS Aurora MySQL クラスターを環境とAZ数に応じて自動的に最適な構成で作成します。

## 🚀 機能

- **環境別自動インスタンス数決定**：dev/stg/prod環境に応じた最適なインスタンス数
- **AZ自動検出**：VPCサブネット構成からAZ数を自動判定
- **柔軟な3AZ設定**：stg・prod環境で2台/3台構成を選択可能
- **AZ配置戦略**：writer=1a固定、reader=1c→1d順の配置

## 📋 環境別構成

### dev環境
```
AZ数: 2つまたは3つ
インスタンス数: 1台
配置: ap-northeast-1a（writer）のみ
```

### stg・prod環境
```
AZ数: 2つの場合
├─ インスタンス数: 2台
└─ 配置: ap-northeast-1a（writer）+ ap-northeast-1c（reader）

AZ数: 3つの場合
├─ use_all_azs_for_aurora = false: 2台構成
│  └─ 配置: ap-northeast-1a（writer）+ ap-northeast-1c（reader）
└─ use_all_azs_for_aurora = true: 3台構成
   └─ 配置: ap-northeast-1a（writer）+ ap-northeast-1c（reader）+ ap-northeast-1d（reader）
```

## ⚙️ 設定例

### コスト重視（2台構成）
```hcl
# terraform.tfvars
use_all_azs_for_aurora = false  # 2台構成でコスト削減
```

### 高可用性重視（3台構成）
```hcl
# terraform.tfvars  
use_all_azs_for_aurora = true   # 3台構成で最大可用性
```

## 📁 必要な設定

### variables.tf
```hcl
variable "use_all_azs_for_aurora" {
  description = "3AZ環境で全AZにAuroraインスタンスを配置するかどうか"
  type        = bool
  default     = false
}
```

### main.tf（モジュール呼び出し）
```hcl
module "rds" {
  source                 = "../../modules/rds"
  # ... その他の設定 ...
  available_azs_count    = module.vpc.vpc_available_azs_count
  use_all_azs_for_aurora = var.use_all_azs_for_aurora
}
```

## 🏷️ 出力情報

モジュールは以下の情報を出力します：

```hcl
# インスタンス数
output "rds_cluster_instance_count" {
  value = local.calculated_instance_count
}

# 配置AZ一覧  
output "rds_cluster_instance_azs" {
  value = local.instance_azs
}

# インスタンス詳細
output "rds_cluster_instance_details" {
  value = [
    {
      id   = "インスタンスID"
      az   = "配置AZ"
      role = "writer/reader"
      promotion_tier = "プロモーション階層"
    }
  ]
}
```

## 💡 使い分けガイド

### 開発フェーズ
- **dev環境**：1台構成で開発コスト最小化
- **stg環境**：`false`設定で2台構成、基本的な冗長性確保

### 本番運用フェーズ
- **stg環境**：`true`設定で3台構成、本番と同等のテスト環境
- **prod環境**：要件に応じて2台/3台を選択

### 障害対応フェーズ
- **すべての環境**：3台構成で最大の可用性確保

## 🔧 トラブルシューティング

### エラー：変数が定義されていない
```
Error: No declaration found for "var.use_all_azs_for_aurora"
```

**解決方法**：環境のvariables.tfに変数定義を追加
```hcl
variable "use_all_azs_for_aurora" {
  description = "3AZ環境で全AZにAuroraインスタンスを配置するかどうか"
  type        = bool
  default     = false
}
```

### 設定確認方法
terraform planで構成を確認：
```bash
terraform plan -var-file="terraform.tfvars"
```

出力例：
```
# module.rds.aws_rds_cluster_instance.terra_rds_cluster_instance[0] will be created
+ availability_zone = "ap-northeast-1a"
+ promotion_tier   = 0  # writer

# module.rds.aws_rds_cluster_instance.terra_rds_cluster_instance[1] will be created  
+ availability_zone = "ap-northeast-1c"
+ promotion_tier   = 1  # reader
```

## 📊 コスト比較

| 構成 | 月額コスト概算* | 可用性 | 用途 |
|------|----------------|--------|------|
| 1台構成 | $50-100 | 低 | 開発環境 |
| 2台構成 | $100-200 | 中 | ステージング・小規模本番 |
| 3台構成 | $150-300 | 高 | 本番環境・ミッションクリティカル |

*db.t4g.mediumの場合の概算値

---

詳細な設定については、各環境のterraform.tfvarsファイルを参照してください。 