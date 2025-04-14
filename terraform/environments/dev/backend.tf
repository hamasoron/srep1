# バックエンドの定義
terraform {
  backend "s3" {
    bucket       = "awshamasoron2"
    key          = "env/dev/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
    encrypt      = true
  }
}