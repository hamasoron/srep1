# リソースの定義
## IAM AccessAnalyzer（外部アクセス分析）の作成
resource "aws_accessanalyzer_analyzer" "terra_accessanalyzer_analyzer" {
  analyzer_name = "CustomExternalAccessAnalyzer"
  type         = var.analyzer_type
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomExternalAccessAnalyzer"
  }
} 