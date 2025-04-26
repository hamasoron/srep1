# バックエンドの定義
## バックエンドをローカルではなくs3に設定
terraform {
  backend "s3" {
    bucket       = "awshamasoron2"
    key          = "env/stg/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
    encrypt      = true
  }
}