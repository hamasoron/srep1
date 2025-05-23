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

## Lambda関数用のIAMロールを作成
resource "aws_iam_role" "terra_iam_role_lambda_rotation" {
  name = var.lambda_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  tags = var.tags
}

## 外部ファイルからIAMポリシーを読み込む
resource "aws_iam_policy" "terra_iam_policy_ecs_task" {
  name   = "CustomECSTaskPolicy"
  policy = file("${path.module}/iam_policy/CustomECSTaskPolicy.json")
}
resource "aws_iam_policy" "terra_iam_policy_ecs_task_execution" {
  name   = "CustomECSTaskExecutionPolicy"
  policy = file("${path.module}/iam_policy/CustomECSTaskExecutionPolicy.json")
}
resource "aws_iam_policy" "terra_iam_policy_github_actions" {
  name   = "CustomGitHubActionsPolicy"
  policy = file("${path.module}/iam_policy/CustomGitHubActionsPolicy.json")
}
resource "aws_iam_policy" "terra_iam_policy_secretsmanager" {
  name        = "CustomLambdaPolicy"
  description = "Allows Lambda function to rotate secrets in SecretsManager"
  policy      = file("${path.module}/iam_policy/CustomLambdaPolicy.json")
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

## Lambda関数用のIAMロールにカスタムポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "terra_iam_role_policy_attachment_secretsmanager" {
  role       = aws_iam_role.terra_iam_role_lambda_rotation.name
  policy_arn = aws_iam_policy.terra_iam_policy_secretsmanager.arn
}

## GitHub OIDC（OpenID Connect）プロバイダーを作成
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}