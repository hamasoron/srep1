# RDS Aurora Module

このモジュールは、AWS Aurora MySQL クラスターをAZ数とデプロイメントモードに応じて柔軟な構成で作成します。

## 🚀 機能

- **AZ数別構成選択**：2AZ・3AZ環境に応じた最適なインスタンス構成
- **デプロイメントモード選択**：Writer単体、Writer+Reader構成を選択可能
- **AZ自動検出**：VPCサブネット構成からAZ数を自動判定
- **柔軟な構成変更**：環境やコスト要件に応じた構成変更が可能

## 📋 デプロイメントモード

### deployment_mode の選択肢

| モード | 説明 | 1AZ環境 | 2AZ環境 | 3AZ環境 |
|--------|------|---------|---------|---------|
| `writer_only` | Writer 1台のみ | 1台構成 | 1台構成 | 1台構成 |
| `writer_with_1_reader` | Writer 1台 + Reader 1台 | 1台構成* | 2台構成 | 2台構成 |
| `writer_with_2_readers` | Writer 1台 + Reader 2台 | 1台構成* | 2台構成** | 3台構成 |

*1AZ環境では物理的制約によりReader配置不可のため、Writer 1台のみ
**2AZ環境では最大2台までの制限があります

## 🌏 東京リージョン（ap-northeast-1）のAZ制約

### 利用可能AZ
- **1a (ap-northeast-1a)**: 常時利用可能
- **1c (ap-northeast-1c)**: 常時利用可能  
- **1d (ap-northeast-1d)**: 常時利用可能
- **1b (ap-northeast-1b)**: 基本的に使用されない

### AZ数による制限
- **最大AZ数**: 3つまで（東京リージョンの物理的制約）
- **推奨構成**: 1a → 1c → 1d の順で配置

## 📊 AZ数別構成表

### 1AZ環境の場合
```
すべてのdeployment_modeで1台構成
└─ ap-northeast-1a（writer）のみ
```

### 2AZ環境の場合
```
├─ writer_only: 1台
│  └─ ap-northeast-1a（writer）
├─ writer_with_1_reader: 2台  
│  └─ ap-northeast-1a（writer）+ ap-northeast-1c（reader）
└─ writer_with_2_readers: 2台（制限により2台まで）
   └─ ap-northeast-1a（writer）+ ap-northeast-1c（reader）
```

### 3AZ環境の場合
```
├─ writer_only: 1台
│  └─ ap-northeast-1a（writer）
├─ writer_with_1_reader: 2台
│  └─ ap-northeast-1a（writer）+ ap-northeast-1c（reader）
└─ writer_with_2_readers: 3台
   └─ ap-northeast-1a（writer）+ ap-northeast-1c（reader）+ ap-northeast-1d（reader）
```

## ⚙️ 設定例

### 基本的な使用方法
```hcl
module "rds" {
  source = "../../modules/rds"
  
  # 基本設定
  system_name      = "myapp"
  environment_name = "prod"
  
  # VPCからの情報（AZ数は自動計算）
  available_azs_names    = module.vpc.vpc_available_azs_names
  private_subnet_ids     = values(module.vpc.vpc_private_subnet_ids)
  
  # デプロイメントモード選択（これだけでインスタンス数が決定）
  deployment_mode = "writer_with_1_reader"
  
  # その他の設定...
}
```

### 環境別推奨設定

#### 開発環境
```hcl
deployment_mode = "writer_only"  # コスト最小化
```

#### ステージング環境
```hcl
deployment_mode = "writer_with_1_reader"  # 基本的な冗長性
```

#### 本番環境
```hcl
# 高可用性重視
deployment_mode = "writer_with_2_readers"  # 最大の読み取り性能と可用性

# コスト重視
deployment_mode = "writer_with_1_reader"   # バランス型
```

## 📁 必要な変数

### 簡略化されたAurora構成変数
```hcl
variable "available_azs_names" {
  description = "VPCで使用されているAZ名のリスト"
  type        = list(string)
  # 例: ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

variable "deployment_mode" {
  description = "デプロイメントモード選択"
  type        = string
  default     = "writer_only"
  validation {
    condition = contains([
      "writer_only",
      "writer_with_1_reader", 
      "writer_with_2_readers"
    ], var.deployment_mode)
    error_message = "deployment_mode must be one of: writer_only, writer_with_1_reader, writer_with_2_readers."
  }
}
```

### 自動計算される値
- **AZ数**: `available_azs_names`のlengthから自動計算
- **インスタンス数**: `deployment_mode`とAZ数から自動決定
- **配置戦略**: AZ名リストの順序で自動配置

## 🏷️ 出力情報

モジュールは以下の情報を出力します：

```hcl
# 基本的なクラスター情報
output "rds_cluster_writer_endpoint" {
  value = aws_rds_cluster.terra_rds_cluster.endpoint
}

output "rds_cluster_reader_endpoint" {
  value = aws_rds_cluster.terra_rds_cluster.reader_endpoint
}

# 新しく追加された構成情報
output "rds_deployment_configuration" {
  value = {
    deployment_mode      = var.deployment_mode
    available_azs_count  = var.available_azs_count
    final_instance_count = local.final_instance_count
    writer_count         = local.selected_config.writer_count
    reader_count         = local.selected_config.reader_count
  }
}

# インスタンス詳細
output "rds_cluster_instance_details" {
  value = [
    {
      id             = "インスタンスID"
      az             = "配置AZ"
      role           = "writer/reader"
      promotion_tier = "プロモーション階層"
    }
  ]
}
```

## 💡 シンプルな使い分けガイド

### 1つの変数で決まる構成選択

| 用途 | deployment_mode | 説明 |
|------|-----------------|------|
| **開発・テスト** | `writer_only` | 最低コスト、シンプル構成 |
| **ステージング** | `writer_with_1_reader` | 基本的な読み取り分散 |
| **本番環境** | `writer_with_2_readers` | 最大の可用性と性能 |

### 自動的に最適化される項目
- **インスタンス数**: AZ数と deployment_mode で自動決定
- **配置戦略**: 1a → 1c → 1d の順で自動配置
- **コスト**: AZ数が少ない環境では自動的にコスト最適化

## 🔧 トラブルシューティング

### 設定確認方法
```bash
terraform plan -var-file="terraform.tfvars"
```

### 構成変更時の注意点
- `deployment_mode`の変更は既存インスタンスの追加・削除を伴います
- 本番環境での変更は必ずメンテナンス時間帯に実施してください
- Reader削除時はアプリケーションの接続設定も確認してください

### 東京リージョン特有の制約
- **1AZ環境でのReader要求**: 1AZ環境で`writer_with_1_reader`や`writer_with_2_readers`を指定してもWriter 1台のみが作成されます
- **AZ1bの使用**: 基本的にap-northeast-1bは使用されません（VPCモジュールの設定による）
- **最大AZ数**: 東京リージョンでは実質3AZまでしか利用できません

## 📊 コスト・パフォーマンス比較

| 構成モード | 1AZ環境 | 2AZ環境 | 3AZ環境 | 月額コスト概算* | 読み取り性能 | 可用性 |
|------------|---------|---------|---------|----------------|-------------|--------|
| writer_only | 1台 | 1台 | 1台 | $50-100 | 低 | 低 |
| writer_with_1_reader | 1台 | 2台 | 2台 | $50-200 | 低-中 | 低-中 |
| writer_with_2_readers | 1台 | 2台 | 3台 | $50-300 | 低-高 | 低-高 |

*db.t4g.mediumの場合の概算値
**1AZ環境では物理的制約により、すべてのモードでWriter 1台のみの構成となります

---

詳細な設定については、各環境のterraform.tfvarsファイルを参照してください。 