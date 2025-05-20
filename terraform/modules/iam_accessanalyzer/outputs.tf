output "iam_accessanalyzer_arn" {
  description = "アナライザーのARN"
  value       = aws_accessanalyzer_analyzer.terra_accessanalyzer_analyzer.arn
}