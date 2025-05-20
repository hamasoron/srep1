# プロバイダーとTerraformのバージョンを定義
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.94.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "= 0.11.2"
    }
  }
  required_version = "= 1.11.3"
}

provider "aws" {
  region = var.region_name
}
