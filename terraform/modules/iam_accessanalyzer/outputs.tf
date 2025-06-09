# アウトプットの定義
## IAM AccessAnalyzer
output "iam_accessanalyzer_arn" {
  description = "ARN of the IAM AccessAnalyzer"
  value       = aws_accessanalyzer_analyzer.terra_accessanalyzer_analyzer.arn
}