# リソースの定義
## ECSタスクロール（起動タイプFargate/EC2）の作成
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

## 外部ファイルからIAMポリシー（ECSタスク用）を読み込む
resource "aws_iam_policy" "terra_iam_policy_ecs_task_policy" {
  name   = "CustomECSTaskPolicy"
  policy = file("${path.module}/iampolicy/CustomECSTaskPolicy.json")
}
resource "aws_iam_policy" "terra_iam_policy_ecs_task_execution_policy" {
  name   = "CustomECSTaskExecutionPolicy"
  policy = file("${path.module}/iampolicy/CustomECSTaskExecutionPolicy.json")
}

## ECSタスクロールにカスタムポリシーをアタッチ
resource "aws_iam_policy_attachment" "terra_iam_policy_attachment_ecs_task_custom" {
  name       = "CustomECSTaskPolicy"
  roles      = [aws_iam_role.terra_iam_role_ecs_task.name]
  policy_arn = aws_iam_policy.terra_iam_policy_ecs_task_policy.arn
}

## ECSタスク実行ロールにカスタムポリシーをアタッチ（SecretsManager用）
resource "aws_iam_policy_attachment" "ecs_task_execution_role_policy_custom" {
  name       = "CustomECSTaskExecutionPolicy"
  roles      = [aws_iam_role.terra_iam_role_ecs_task_execution.name]
  policy_arn = aws_iam_policy.terra_iam_policy_ecs_task_execution_policy.arn
}

# GitHub Actions用のIAMロール
resource "aws_iam_role" "github_actions_role" {
  name = "${var.system_name}-${var.environment_name}-github-actions-role"

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

  tags = {
    Name = "${var.system_name}-${var.environment_name}-github-actions-role"
  }
}

# GitHub OIDCプロバイダー
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# GitHub Actions用のIAMポリシー
resource "aws_iam_policy" "github_actions_policy" {
  name        = "${var.system_name}-${var.environment_name}-github-actions-policy"
  description = "Policy for GitHub Actions to push to ECR and deploy to ECS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecs:UpdateService",
          "ecs:RunTask",
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringLike = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}

# ポリシーをロールにアタッチ
resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}