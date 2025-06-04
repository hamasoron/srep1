# アウトプットの定義
## IAM AccessAnalyzer
output "iam_accessanalyzer_arn" {
  description = "Analyzer ARN"
  value       = aws_accessanalyzer_analyzer.terra_accessanalyzer_analyzer.arn
}