# Terraform AWS Infrastructure

このプロジェクトは、AWS上にスケーラブルなWebアプリケーション基盤を構築するTerraformコードです。

## 🏗️ アーキテクチャ

- **VPC**: マルチAZ対応のネットワーク基盤
- **Aurora MySQL**: 環境別最適化されたデータベースクラスター  
- **ECS Fargate**: コンテナ化されたアプリケーション
- **ALB**: ロードバランシング
- **Lambda**: データベース認証情報ローテーション

## 📁 ディレクトリ構成

```
terraform/
├── modules/           # 再利用可能なモジュール
│   ├── vpc/          # VPCとネットワーク設定
│   ├── rds/          # Aurora MySQL設定
│   ├── ecs/          # ECSクラスターとサービス
│   └── ...
└── environments/     # 環境別設定
    ├── dev/          # 開発環境
    ├── stg/          # ステージング環境
    └── prod/         # 本番環境
```

## 🗄️ Aurora設定

### 環境別インスタンス構成

| 環境 | AZ数 | インスタンス数 | 配置 | 用途 |
|------|------|----------------|------|------|
| dev | 2/3 | 1台 | 1a（writer） | 開発・テスト |
| stg | 2 | 2台 | 1a（writer）+ 1c（reader） | ステージング |
| stg | 3 | 2台/3台選択可能 | 設定により2台または3台 | 本番同等テスト |
| prod | 2 | 2台 | 1a（writer）+ 1c（reader） | 本番運用 |
| prod | 3 | 2台/3台選択可能 | 設定により2台または3台 | 本番運用 |

### 3AZ環境での設定例

#### コスト重視（推奨：stg環境）
```hcl
# terraform/environments/stg/terraform.tfvars
use_all_azs_for_aurora = false  # 2台構成（1a + 1c）
```

#### 高可用性重視（推奨：prod環境）
```hcl
# terraform/environments/prod/terraform.tfvars
use_all_azs_for_aurora = true   # 3台構成（1a + 1c + 1d）
```

## 🚀 デプロイ手順

### 1. 環境の初期化
```bash
cd terraform/environments/dev
terraform init
```

### 2. 設定の確認
```bash
terraform plan -var-file="terraform.tfvars"
```

### 3. インフラの作成
```bash
terraform apply -var-file="terraform.tfvars"
```

## ⚙️ 主要設定ファイル

### terraform.tfvars（各環境）
```hcl
# 基本設定
region_name      = "ap-northeast-1"
system_name      = "srep1"
environment_name = "dev"  # dev/stg/prod

# Aurora設定
use_all_azs_for_aurora = false  # 3AZ時の台数選択

# VPC設定
subnet_list = [
  { name = "1a", cidr_block = "10.0.64.0/24", type = "public" },
  { name = "1c", cidr_block = "10.0.65.0/24", type = "public" },
  # 3AZ構成の場合は1dも追加
  { name = "1d", cidr_block = "10.0.66.0/24", type = "public" },
]
```

## 📊 リソース作成数

### dev環境（2AZ構成）
- Aurora: 1台（1a）
- NAT Gateway: 1台（1a）
- 月額コスト概算: $100-150

### stg環境（3AZ構成、2台）
- Aurora: 2台（1a + 1c）  
- NAT Gateway: 2台（1a + 1c）
- 月額コスト概算: $200-300

### prod環境（3AZ構成、3台）
- Aurora: 3台（1a + 1c + 1d）
- NAT Gateway: 3台（1a + 1c + 1d）
- 月額コスト概算: $350-500

## 🔧 運用ガイド

### Aurora台数変更
```bash
# 2台から3台に変更
vim terraform.tfvars
# use_all_azs_for_aurora = false → true

terraform plan
terraform apply
```

### 環境別推奨設定
```hcl
# dev環境：コスト最優先
nat_gateway_list = [
  { az = "1a", enabled = true },
  { az = "1c", enabled = false },
]
use_all_azs_for_aurora = false  # 無視される（常に1台）

# stg環境：開発段階
nat_gateway_list = [
  { az = "1a", enabled = true },
  { az = "1c", enabled = true },
  { az = "1d", enabled = false },
]
use_all_azs_for_aurora = false  # 2台構成

# prod環境：本番運用
nat_gateway_list = [
  { az = "1a", enabled = true },
  { az = "1c", enabled = true },
  { az = "1d", enabled = true },
]
use_all_azs_for_aurora = true   # 3台構成
```

## 🆘 トラブルシューティング

### よくあるエラー

#### 1. 変数未定義エラー
```
Error: No declaration found for "var.use_all_azs_for_aurora"
```
**解決**: `variables.tf`に変数定義を追加

#### 2. AZ不足エラー  
```
Error: insufficient capacity for Aurora instances
```
**解決**: `subnet_list`で必要なAZのサブネットを定義

#### 3. 設定確認方法
```bash
# 作成されるAuroraインスタンス数を確認
terraform plan | grep "aws_rds_cluster_instance"

# 出力例
# + aws_rds_cluster_instance.terra_rds_cluster_instance[0]
# + aws_rds_cluster_instance.terra_rds_cluster_instance[1] 
```

## 📚 詳細ドキュメント

- [RDS Auroraモジュール](./modules/rds/README.md) - Aurora設定の詳細
- [VPCモジュール](./modules/vpc/) - ネットワーク構成
- [ECSモジュール](./modules/ecs/) - アプリケーション設定

---

質問や問題がある場合は、各モジュールのREADME.mdを参照するか、プロジェクトチームにお問い合わせください。 