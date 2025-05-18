# アウトプットの定義
output "ecr_repository_urls" {
  description = "マップ形式のECRリポジトリのURL（ECSモジュールのタスク定義のイメージURLとして使用）"
  value = {
    for name, repo in aws_ecr_repository.terra_ecr_repository :
    name => repo.repository_url
  }
}