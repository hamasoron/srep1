# terraform_project
## Directory Structure

```
terraform_project/                   # プロジェクトのルートディレクトリ
├── .git/                            # Gitリポジトリのディレクトリ（git init時に自動作成）
├── .gitignore                       # Gitで無視する（管理しない）ファイルやディレクトリのリスト
├── modules/                         # 再利用可能なTerraformのモジュールを格納
│   ├── vpc/                         # VPC関連のモジュール
│   │   ├── main.tf                  # VPCのリソース定義
│   │   ├── variables.tf             # VPCモジュールの変数定義
│   │   └── outputs.tf               # VPCモジュールの出力値定義
│   ├── sg/                          # SG関連のモジュール
│   │   ├── main.tf                  # SGのリソース定義
│   │   ├── variables.tf             # SGモジュールの変数定義
│   │   └── outputs.tf               # SGモジュールの出力値定義
│   ├── iamrole/                     # IAMROLE関連のモジュール
│   │   ├── main.tf                  # IAMROLEのリソース定義
│   │   ├── variables.tf             # IAMROLEモジュールの変数定義
│   │   └── outputs.tf               # IAMROLEモジュールの出力値定義
│   └── ec2/                         # EC2関連のモジュール
│       ├── main.tf                  # EC2のリソース定義
│       ├── variables.tf             # EC2モジュールの変数定義
│       └── outputs.tf               # EC2モジュールの出力値定義
├── environments/                    # 環境ごとのTerraform設定（本番、検証、開発）
│   ├── prod/                        # 本番環境の設定
│   │   ├── .terraform               # 本番環境のprovider.tf記載のプロバイダーとやり取りをするためのプラグインをダウンロード（terraform initで自動作成）
│   │   ├── terraform.lock.hcl       # 本番環境のプロバイダーのバージョンをロックするためのファイル（terraform initで自動作成）
│   │   ├── terraform.tfvars         # 本番環境の変数値（パラメータ）
│   │   ├── main.tf                  # 本番環境のリソース定義
│   │   ├── variables.tf             # 本番環境の変数定義
│   │   ├── outputs.tf               # 本番環境の出力値定義
│   │   ├── provider.tf              # 本番環境のプロバイダーとTerraformのバージョン設定
│   │   └── backend.tf               # 本番環境のバックエンド設定（S3の格納先など）
│   ├── stg/                         # 検証環境の設定
│   │   ├── .terraform/              # 検証環境のprovider.tf記載のプロバイダーとやり取りをするためのプラグインをダウンロード（terraform initで自動作成）
│   │   ├── terraform.lock.hcl       # 検証環境のプロバイダーのバージョンをロックするためのファイル（terraform initで自動作成）
│   │   ├── terraform.tfvars         # 検証環境の変数値（パラメータ）
│   │   ├── main.tf                  # 検証環境のリソース定義
│   │   ├── variables.tf             # 検証環境の変数定義
│   │   ├── outputs.tf               # 検証環境の出力値定義
│   │   ├── provider.tf              # 検証環境のプロバイダーとTerraformのバージョン設定
│   │   └── backend.tf               # 検証環境のバックエンド設定（S3の格納先など）
│   └── dev/                         # 開発環境の設定
│       ├── .terraform/              # 開発環境のprovider.tf記載のプロバイダーとやり取りをするためのプラグインをダウンロード（terraform initで自動作成）
│       ├── terraform.lock.hcl       # 開発環境のプロバイダーのバージョンをロックするためのファイル（terraform initで自動作成）
│       ├── terraform.tfvars         # 開発環境の変数値（パラメータ）
│       ├── main.tf                  # 開発環境のリソース定義
│       ├── variables.tf             # 開発環境の変数定義
│       ├── outputs.tf               # 開発環境の出力値定義
│   │   ├── provider.tf              # 開発環境のプロバイダーとTerraformのバージョン設定
│       └── backend.tf               # 開発環境のバックエンド設定（S3の格納先など）
├── documents/                       # 各種ドキュメントを格納
├── scripts/                         # 各種スクリプトを格納
└── README.md                        # プロジェクトの概要や使用方法等のドキュメント
```

## How To Use
### 作成・実行手順
#### 1. コードの自動整形（インデントやスペースの自動調整）［カレントディレクトリまたはサブディレクトリも含める］
```bash
terraform fmt
```
```bash
terraform fmt -recursive
```
#### 2. 各環境（prod/stg/dev）ディレクトリに移動
```bash
cd environments/prod/
```
```bash
cd environments/stg/
```
```bash
cd environments/dev/
```
#### 3. Terraformディレクトリの初期化（.terraformとterraform.lock.hclが自動作成かつbackend.tfと連携）
```bash
terraform init
```
#### 4. プランの作成（明示的にterraform.tfvarsを指定しても良いが環境ごとに分けているため記述不要）
##### （1） 一括
```bash
terraform plan
```
##### （2） モジュール単位（非推奨）
```bash
terraform plan -target="module.vpc"
```
```bash
terraform plan -target="module.sg"
```
#### 5. プランの適用（明示的にterraform.tfvarsを指定しても良いが環境ごとに分けているため記述不要）
##### （1） 一括
```bash
terraform apply
```
##### （2） モジュール単位（非推奨）
```bash
terraform apply -target="module.vpc"
```
```bash
terraform apply -target="module.sg"
```
```bash
terraform apply -target="module.iamrole"
```
```bash
terraform apply -target="module.ec2"
```
### 削除手順
#### 1. プランの削除
##### （1） 一括（明示的にterraform.tfvarsを指定しても良いが環境ごとに分けているため記述不要）
```bash
terraform destroy
```
##### （2） モジュール単位（非推奨）
```bash
terraform apply -target="module.ec2"
```
```bash
terraform apply -target="module.iamrole"
```
```bash
terraform destroy -target="module.sg"
```
```bash
terraform destroy -target="module.vpc"
```

## Variable Determination Order
### 1.　変数の流れ
Terraformでは、変数の値は **ルートモジュール** から **モジュールへ** 渡されます。  
その際、以下のような優先順位で決定されます。
#### （1） ルートモジュールのterraform.tfvars
（例）
```hcl
region_name = "us-east-1"
vpc_cidr    = "10.0.0.0/16"
```

#### （2） ルートモジュールのvariables.tf内のデフォルト値
（例）
```hcl
variable "region_name" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}
```
#### （3） ルートモジュールのmain.tfでmodulesに渡す
（例）
```hcl
module "vpc" {
  source       = "../../modules/vpc"
  region_name  = var.region_name  # ルートモジュールの変数（1）または（2）をモジュールに渡す
  vpc_cidr     = var.vpc_cidr
}
```
#### （4） modules/vpc/variables.tfで受け取る
（例）
```hcl
variable "region_name" {
  description = "デプロイするAWSリージョン"
  type        = string
}

variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type        = string
}
```
ここで受け取った変数を、モジュールのmain.tfなどで使う
```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}
```

## terraform自体のバージョンの確認と更新方法
### 1. terraform自体のバージョンを確認
```bash
terraform -v
```
### 2. terraform自体のバージョンを更新
#### （1） Terraformの公式サイトから最新バージョン（amd64）をダウンロード
https://developer.hashicorp.com/terraform/install
#### （2） ダウンロードしたファイルを解凍
#### （3） 解凍したファイル（terraform.exe）を適切なディレクトリ（例：C:\Terraform\）に移動
#### （4） システムのプロパティ（sysdm.cpl）を起動
#### （5） 詳細設定 → 環境変数を選択
#### （6） ユーザー環境変数のPath変数を編集し、C:\Terraformを追加
### 3. 再度terraform自体のバージョンを確認
```bash
terraform -v
```

## terraformのプロバイダー（aws）のバージョンの確認と更新方法
### 1. terraformのプロバイダー（aws）のバージョンを確認
```bash
cd environments/prod/
terraform init
type .\.terraform.lock.hcl
```
### 2. terraformのプロバイダー（aws）のバージョンを更新（provider.tfに設定されている範囲でプロバイダーのバージョンを更新可能）
#### （1） Terraformの公式サイトからプロバイダー（aws）の最新バージョンを確認
https://registry.terraform.io/namespaces/hashicorp
#### （2） provider.tfのバージョンを確認（場合によってはバージョンの設定範囲を最新バージョンに変更）
```bash
# Terraformとプロバイダーのバージョンを定義
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.93" ### セマンティックバージョニング（5.93.0以上、5.94.0未満の範囲で手動更新可能）
    }
  }
  required_version = ">= 1.10, < 2.0" ### セマンティックバージョニング（1.10.0以上、2.0.0未満の範囲で手動更新）
}

# プロバイダーの定義
provider "aws" {
  region = var.region_name
}
```
#### （3） terraformのプロバイダー（aws）のバージョンを更新（provider.tfに設定されている範囲でプロバイダーのバージョンを更新可能）
```bash
terraform init -upgrade
```
### 3. 再度terraformのプロバイダー（aws）のバージョンを確認
```bash
cd environments/prod/
type .\.terraform.lock.hcl
```
### 4.［補足］.terraform.lock.hclファイルをバージョン管理システム（例: Git）にコミットし、チーム全体で一貫したプロバイダーのバージョンを使用。環境間でのバージョンの不整合を防ぐことが可能