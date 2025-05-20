# バックエンドの定義
## バックエンドをローカルではなくs3に設定
terraform {
  backend "s3" {
    bucket       = "srep1-tfstate-backend"
    key          = "env/prod/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
    encrypt      = true
  }
}