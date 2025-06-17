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
│   │   ├── provider.tf              # 本番環境のプロバイダーとTerraformのバージョンの定義
│   │   └── backend.tf               # 本番環境のバックエンド設定（S3の格納先など）
│   ├── stg/                         # 検証環境の設定
│   │   ├── .terraform/              # 検証環境のprovider.tf記載のプロバイダーとやり取りをするためのプラグインをダウンロード（terraform initで自動作成）
│   │   ├── terraform.lock.hcl       # 検証環境のプロバイダーのバージョンをロックするためのファイル（terraform initで自動作成）
│   │   ├── terraform.tfvars         # 検証環境の変数値（パラメータ）
│   │   ├── main.tf                  # 検証環境のリソース定義
│   │   ├── variables.tf             # 検証環境の変数定義
│   │   ├── outputs.tf               # 検証環境の出力値定義
│   │   ├── provider.tf              # 検証環境のプロバイダーとTerraformのバージョンの定義
│   │   └── backend.tf               # 検証環境のバックエンド設定（S3の格納先など）
│   └── dev/                         # 開発環境の設定
│       ├── .terraform/              # 開発環境のprovider.tf記載のプロバイダーとやり取りをするためのプラグインをダウンロード（terraform initで自動作成）
│       ├── terraform.lock.hcl       # 開発環境のプロバイダーのバージョンをロックするためのファイル（terraform initで自動作成）
│       ├── terraform.tfvars         # 開発環境の変数値（パラメータ）
│       ├── main.tf                  # 開発環境のリソース定義
│       ├── variables.tf             # 開発環境の変数定義
│       ├── outputs.tf               # 開発環境の出力値定義
│       ├── provider.tf              # 開発環境のプロバイダーとTerraformのバージョンの定義
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
#### （4） modules/vpc/variables.tfで受け取る（受け取ってないものについてはデフォルト値を使用）
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

### 5.使用方法
#### （1） 外部レジストラからドメインの購入
#### （2） Route53のモジュールの作成
```bash
terraform apply -target="module.route53_zone"
```
#### （3） 外部レジストラとRoute53の紐付けを手動実行し名前解決できるか確認（最大48時間かかる）
```bash
dig @9.9.9.9 srep1.jp NS
nslookup -type=NS srep1.jp 9.9.9.9
```
#### （4） その他のモジュールの作成（Route53とACMのドメイン検証が自動で実行される）
```bash
terraform apply
```
#### （5） 各種CICDの実行（ECRの初回ビルドが自動で実行される）
```bash
cd .github/workflows/
.trigger-all.txtを編集
git add .trigger-all.txt
git commit -m "2025-05-27 22:00 triggered for all CI/CD test"
git push
```
#### （6）ECSワンショットタスクの実行
```bash
コンソールからECSワンショットタスクを実行
```
#### （7）再度モジュールの作成（ECSやappユーザーの初回ローテーションの実行）
```bash
terraform apply
```

### 6.二回目以降の作成
#### （1） プランの適用
```bash
terraform apply

### モジュール間のoutputs.tfの出力値を参照する流れ
[子モジュールA (Route53)]
   │
   ├─ outputs.tf（出力）
   │     ↓
[親モジュール (root module)]
   │
   ├─ module "route53"の出力値として受け取る
   │
   └─ module "acm"のvariables.tfへ渡す（入力）
         ↓
[子モジュールB (ACM)]
   │
   ├─ variables.tf（入力として受け取る）
   │
   └─ main.tf（var.zone_id等として参照）
```
子モジュールAのoutputs.tf
```hcl
output "route53_zone_id" {
  value = aws_route53_zone.terra_route53_zone.zone_id
}
```
親モジュールのmain.tf
```hcl
module "route53" {
  source = "../modules/route53"
  # 必要な変数
}

module "acm" {
  source  = "../modules/acm"
  zone_id = module.route53.route53_zone_id
  # 他の変数
}
```
子モジュールBのvariables.tf
```hcl
variable "zone_id" {
  type        = string
  description = "ACMのDNS検証レコードを作成するために必要なRoute53ホストゾーンID"
}
```
子モジュールBのmain.tf
```hcl
resource "aws_route53_record" "terra_acm_certificate_validation_record" {
  zone_id = var.zone_id  # ここで親経由で受け取った値を使う
  # 他の設定
}
```

### 作成リソースの確認（最強パターン）
#### （1） サービス名等を指定してリソースを抽出
```bash
terraform state list | Select-String route53（サービス名）
```
```bash
terraform state list | grep route53（サービス名）
```

module.route53.aws_route53_record.terra_route53_record
module.route53.aws_route53_zone.terra_route53_zone

#### （2） リソースのIDを指定してリソースを抽出
```bash
terraform state show module.route53.aws_route53_record.terra_route53_record（リソース名）
```
```bash
terraform state show module.route53.aws_route53_zone.terra_route53_zone（リソース名）
```


resource "aws_route53_record" "terra_route53_record" {
    fqdn                             = "dev.srep1.jp"
    health_check_id                  = null
    id                               = "Z02521503PM8RAQD26F3Y_dev.srep1.jp_CAA"
    multivalue_answer_routing_policy = false
    name                             = "dev.srep1.jp"
    records                          = [
        "0 issue \"amazon.com\"",
    ]
    set_identifier                   = null
    ttl                              = 3600
    type                             = "CAA"
    zone_id                          = "Z02521503PM8RAQD26F3Y"
}

#### ECSexecのログイン
```bash
aws ecs execute-command --cluster srep1-ecs-cluster --task タスクID --container nginx --interactive --command "/bin/sh"
```