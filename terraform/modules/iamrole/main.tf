# リソースの定義
## ECSタスクロール（起動タイプFargate）の作成
resource "aws_iam_role" "terra_iam_role_ecs_task" {
  name = "CustomECSTaskRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

## ECSタスク実行ロール（起動タイプFargate）の作成
resource "aws_iam_role" "terra_iam_role_ecs_task_execution" {
  name = "CustomECSTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

## GitHub Actions用のIAMロールを作成
resource "aws_iam_role" "terra_iam_role_github_actions" {
  name = "CustomGitHubActionsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
        }
      }
    ]
  })
}

## 外部ファイルからIAMポリシー（ECSタスク用）を読み込む
resource "aws_iam_policy" "terra_iam_policy_ecs_task" {
  name   = "CustomECSTaskPolicy"
  policy = file("${path.module}/iampolicy/CustomECSTaskPolicy.json")
}
resource "aws_iam_policy" "terra_iam_policy_ecs_task_execution" {
  name   = "CustomECSTaskExecutionPolicy"
  policy = file("${path.module}/iampolicy/CustomECSTaskExecutionPolicy.json")
}
resource "aws_iam_policy" "terra_iam_policy_github_actions" {
  name   = "CustomGitHubActionsPolicy"
  policy = file("${path.module}/iampolicy/CustomGitHubActionsPolicy.json")
}

## ECSタスクロールにカスタムポリシーをアタッチ
resource "aws_iam_policy_attachment" "terra_iam_policy_attachment_ecs_task" {
  name       = "CustomECSTaskPolicy"
  roles      = [aws_iam_role.terra_iam_role_ecs_task.name]
  policy_arn = aws_iam_policy.terra_iam_policy_ecs_task.arn
}

## ECSタスク実行ロールにカスタムポリシーをアタッチ（SecretsManager用）
resource "aws_iam_policy_attachment" "terra_iam_policy_attachment_ecs_task_execution" {
  name       = "CustomECSTaskExecutionPolicy"
  roles      = [aws_iam_role.terra_iam_role_ecs_task_execution.name]
  policy_arn = aws_iam_policy.terra_iam_policy_ecs_task_execution.arn
}

## GitHub Actionsロールにカスタムポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "terra_iam_role_policy_attachment_github_actions" {
  role       = aws_iam_role.terra_iam_role_github_actions.name
  policy_arn = aws_iam_policy.terra_iam_policy_github_actions.arn
}

# GitHub OIDCプロバイダーを作成
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}