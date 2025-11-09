# データリソースの定義
## 現在のAWSアカウントのIDを取得
data "aws_caller_identity" "terra_caller_identity" {
}

# リソースの定義
## ECSタスクロール（起動タイプFargate）の作成
resource "aws_iam_role" "terra_iam_role_ecs_task" {
  name = "CustomECSTaskRole"
  description = "Custom IAM role for ECS tasks"
  max_session_duration = 3600 ##### セッションを保持する時間（1時間~12時間の間で設定）
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
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomECSTaskRole"
  }
}

## ECSタスク実行ロール（起動タイプFargate）の作成
resource "aws_iam_role" "terra_iam_role_ecs_task_execution" {
  name = "CustomECSTaskExecutionRole"
  description = "Custom IAM role for ECS task execution"
  max_session_duration = 3600 ##### セッションを保持する時間（1時間~12時間の間で設定）
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
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomECSTaskExecutionRole"
  }
}

## マスターユーザー用Lambda関数のIAMロールを作成
resource "aws_iam_role" "terra_iam_role_lambda_master_rotation" {
  name = "CustomLambdaMasterRotationRole"
  description = "Custom IAM role for Lambda master rotation"
  max_session_duration = 3600 ##### セッションを保持する時間（1時間~12時間の間で設定）
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomLambdaMasterRotationRole"
  }
}

## アプリユーザー用Lambda関数のIAMロールを作成
resource "aws_iam_role" "terra_iam_role_lambda_app_rotation" {
  name = "CustomLambdaAppRotationRole"
  description = "Custom IAM role for Lambda app rotation"
  max_session_duration = 3600 ##### セッションを保持する時間（1時間~12時間の間で設定）
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomLambdaAppRotationRole"
  }
}

## RDSの拡張モニタリング用のIAMロールを作成
resource "aws_iam_role" "terra_iam_role_rds_enhanced_monitoring" {
  name = "CustomRDSEnhancedMonitoringRole"
  description = "Custom IAM role for RDS enhanced monitoring"
  max_session_duration = 3600 ##### セッションを保持する時間（1時間~12時間の間で設定）
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomRDSEnhancedMonitoringRole"
  }
}

### CloudFormation StackSets（管理者用:StackSetの作成、更新、削除）のIAMロールを作成
resource "aws_iam_role" "terra_iam_role_cloudformation_stacksets_administration" {
  name = "CustomCloudFormationStackSetAdministrationRole"
  description = "Custom IAM role for CloudFormation StackSets administration"
  max_session_duration = 3600 ##### セッションを保持する時間（1時間~12時間の間で設定）
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudformation.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomCloudFormationStackSetAdministrationRole"
  }
}

### CloudFormation StackSets（実行用:各リージョンでスタックのリソースを作成、更新、削除）のIAMロールを作成
resource "aws_iam_role" "terra_iam_role_cloudformation_stacksets_execution" {
  name = "CustomCloudFormationStackSetExecutionRole"
  description = "Custom IAM role for CloudFormation StackSets execution"
  max_session_duration = 3600 ##### セッションを保持する時間（1時間~12時間の間で設定）
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.terra_caller_identity.account_id}:role/CustomCloudFormationStackSetAdministrationRole"
        }
      }
    ]
  })
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomCloudFormationStackSetExecutionRole"
  }
}

## Amazon Q Developer用のIAMロールを作成
resource "aws_iam_role" "terra_iam_role_q_developer" {
  name = "CustomQDeveloperRole"
  description = "Custom IAM role for Amazon Q Developer"
  max_session_duration = 3600 ##### セッションを保持する時間（1時間~12時間の間で設定）
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomQDeveloperRole"
  }
}

## GitHub Actions用のIAMロールを作成
resource "aws_iam_role" "terra_iam_role_github_actions" {
  name = "CustomGitHubActionsRole"
  description = "Custom IAM role for GitHub Actions"
  max_session_duration = 3600 ##### セッションを保持する時間（1時間~12時間の間で設定）
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
    Name = "${var.system_name}-${var.environment_name}-CustomGitHubActionsRole"
  }
}

## 外部ファイルからIAMポリシーを読み込む
resource "aws_iam_policy" "terra_iam_policy_ecs_task" {
  name   = "CustomECSTaskPolicy"
  description = "Custom IAM policy for ECS tasks"
  policy = file("${path.module}/iam_policy/CustomECSTaskPolicy.json")
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomECSTaskPolicy"
  }
}
resource "aws_iam_policy" "terra_iam_policy_ecs_task_execution" {
  name   = "CustomECSTaskExecutionPolicy"
  description = "Custom IAM policy for ECS task execution"
  policy = file("${path.module}/iam_policy/CustomECSTaskExecutionPolicy.json")
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomECSTaskExecutionPolicy"
  }
}
resource "aws_iam_policy" "terra_iam_policy_master_lambda" {
  name        = "CustomMasterLambdaPolicy"
  description = "Custom IAM policy for master Lambda function"
  policy      = file("${path.module}/iam_policy/CustomMasterLambdaPolicy.json")
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomMasterLambdaPolicy"
  }
}
resource "aws_iam_policy" "terra_iam_policy_app_lambda" {
  name        = "CustomAppLambdaPolicy"
  description = "Custom IAM policy for app Lambda function"
  policy      = file("${path.module}/iam_policy/CustomAppLambdaPolicy.json")
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomAppLambdaPolicy"
  }
}
resource "aws_iam_policy" "terra_iam_policy_rds_enhanced_monitoring" {
  name        = "CustomRDSEnhancedMonitoringPolicy"
  description = "Custom IAM policy for RDS enhanced monitoring"
  policy      = file("${path.module}/iam_policy/CustomRDSEnhancedMonitoringPolicy.json")
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomRDSEnhancedMonitoringPolicy"
  }
}

resource "aws_iam_policy" "terra_iam_policy_stacksets_administration" {
  name = "CustomCloudFormationStackSetAdministrationPolicy"
  description = "Custom IAM policy for CloudFormation StackSets administration"
  policy = file("${path.module}/iam_policy/CustomCloudFormationStackSetAdministrationPolicy.json")
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomCloudFormationStackSetAdministrationPolicy"
  }
}

resource "aws_iam_policy" "terra_iam_policy_stacksets_execution" {
  name = "CustomCloudFormationStackSetExecutionPolicy"
  description = "Custom IAM policy for CloudFormation StackSets execution"
  policy = file("${path.module}/iam_policy/CustomCloudFormationStackSetExecutionPolicy.json")
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomCloudFormationStackSetExecutionPolicy"
  }
}

resource "aws_iam_policy" "terra_iam_policy_github_actions" {
  name   = "CustomGitHubActionsPolicy"
  description = "Custom IAM policy for GitHub Actions"
  policy = file("${path.module}/iam_policy/CustomGitHubActionsPolicy.json")
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomGitHubActionsPolicy"
  }
}

resource "aws_iam_policy" "terra_iam_policy_q_developer" {
  name   = "CustomQDeveloperPolicy"
  description = "Custom IAM policy for Amazon Q Developer"
  policy = file("${path.module}/iam_policy/CustomQDeveloperPolicy.json")
  tags = {
    Name = "${var.system_name}-${var.environment_name}-CustomQDeveloperPolicy"
  }
}

## ECSタスクロールにカスタムポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "terra_iam_policy_attachment_ecs_task" {
  role       = aws_iam_role.terra_iam_role_ecs_task.name
  policy_arn = aws_iam_policy.terra_iam_policy_ecs_task.arn
}

## ECSタスク実行ロールにカスタムポリシーをアタッチ（SecretsManager用）
resource "aws_iam_role_policy_attachment" "terra_iam_policy_attachment_ecs_task_execution" {
  role       = aws_iam_role.terra_iam_role_ecs_task_execution.name
  policy_arn = aws_iam_policy.terra_iam_policy_ecs_task_execution.arn
}

## マスターユーザー用Lambda関数のIAMロールにカスタムポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "terra_iam_role_policy_attachment_master_lambda" {
  role       = aws_iam_role.terra_iam_role_lambda_master_rotation.name
  policy_arn = aws_iam_policy.terra_iam_policy_master_lambda.arn
}

## アプリユーザー用Lambda関数のIAMロールにカスタムポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "terra_iam_role_policy_attachment_app_lambda" {
  role       = aws_iam_role.terra_iam_role_lambda_app_rotation.name
  policy_arn = aws_iam_policy.terra_iam_policy_app_lambda.arn
}

## RDS Enhanced Monitoringロールにカスタムポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "terra_iam_role_policy_attachment_rds_enhanced_monitoring" {
  role       = aws_iam_role.terra_iam_role_rds_enhanced_monitoring.name
  policy_arn = aws_iam_policy.terra_iam_policy_rds_enhanced_monitoring.arn
}

## CloudFormation StackSets（管理者用:StackSetの作成、更新、削除）用のカスタムポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "terra_iam_policy_attachment_stacksets_administration" {
  role       = aws_iam_role.terra_iam_role_cloudformation_stacksets_administration.name
  policy_arn = aws_iam_policy.terra_iam_policy_stacksets_administration.arn
}

## CloudFormation StackSets（実行用:各リージョンでスタックのリソースを作成、更新、削除）用のカスタムポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "terra_iam_policy_attachment_stacksets_execution" {
  role       = aws_iam_role.terra_iam_role_cloudformation_stacksets_execution.name
  policy_arn = aws_iam_policy.terra_iam_policy_stacksets_execution.arn
}

## GitHub Actionsロールにカスタムポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "terra_iam_role_policy_attachment_github_actions" {
  role       = aws_iam_role.terra_iam_role_github_actions.name
  policy_arn = aws_iam_policy.terra_iam_policy_github_actions.arn
}

## Amazon Q Developerロールにカスタムポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "terra_iam_role_policy_attachment_q_developer" {
  role       = aws_iam_role.terra_iam_role_q_developer.name
  policy_arn = aws_iam_policy.terra_iam_policy_q_developer.arn
}

## GitHub OIDC（OpenID Connect）プロバイダーを作成
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
