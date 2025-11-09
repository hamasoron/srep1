# GuardDuty CFn モジュール

このモジュールは、TerraformからCloudFormation StackSetsを使用してAWS GuardDutyを全リージョンで効率的に有効化するためのものです。

## 概要

参考記事: [Terraformのfor_eachとCFnのStackSetsを使って、効率良くGuardDutyを全リージョンで有効化する方法](https://zenn.dev/falcon_tech/articles/dce0abb42b89eb)

このモジュールは以下の機能を提供します：

- CloudFormation StackSetsを使用した全リージョンでのGuardDuty有効化
- リージョン別の個別設定対応
- 包括的なGuardDuty機能の設定（S3保護、ランタイム監視、RDS保護など）
- 必要なIAMロールの自動作成

## アーキテクチャ

```
Terraform → CloudFormation StackSets → 複数リージョン → GuardDuty有効化
```

## 使用方法

### 基本的な使用例

```hcl
# 事前にStackSets用のIAMロールを作成
module "iam_role" {
  source = "./modules/iam_role"
  
  system_name      = "your-system"
  environment_name = "prod"
  github_repo      = "your-org/your-repo"
  
  # StackSets用のIAMロールを有効化
  enable_cloudformation_stacksets_roles = true
  stacksets_role_name_prefix            = "GuardDuty-"
}

module "guardduty_cfn" {
  source = "./modules/guardduty_cfn"

  name_prefix = "MyOrg-"
  tags = {
    Environment = "production"
    Project     = "security"
    ManagedBy   = "terraform"
  }
  
  # IAMロール設定（iam_roleモジュールから取得）
  stacksets_administration_role_arn = module.iam_role.iam_role_stacksets_administration_arn
  stacksets_execution_role_name     = module.iam_role.iam_role_stacksets_execution_name

  # 対象リージョンの指定
  target_regions = [
    "us-east-1",
    "us-west-2",
    "ap-northeast-1",
    "eu-west-1"
  ]
}
```

### 高度な設定例

```hcl
module "guardduty_cfn" {
  source = "./modules/guardduty_cfn"

  name_prefix = "MyOrg-"
  tags = {
    Environment = "production"
    Project     = "security"
    ManagedBy   = "terraform"
    Owner       = "security-team"
  }

  # 全リージョンを対象とする場合
  target_regions = [
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
    "ap-south-1",
    "ap-northeast-3",
    "ap-northeast-2",
    "ap-southeast-1",
    "ap-southeast-2",
    "ap-northeast-1",
    "ca-central-1",
    "eu-central-1",
    "eu-west-1",
    "eu-west-2",
    "eu-west-3",
    "eu-north-1",
    "sa-east-1"
  ]

  # デフォルト設定
  default_s3_protection                 = "ENABLED"
  default_runtime_monitoring            = "ENABLED"
  default_ecs_fargate_agent_management = "ENABLED"
  default_rds_protection               = "ENABLED"
  default_lambda_protection            = "ENABLED"
  default_eks_audit_logs               = "ENABLED"
  default_ebs_malware_protection       = "DISABLED"
  finding_publishing_frequency          = "ONE_HOUR"

  # リージョン別個別設定
  region_specific_config = {
    "ap-northeast-1" = {
      s3_protection                 = "ENABLED"
      runtime_monitoring            = "ENABLED"
      ecs_fargate_agent_management = "ENABLED"
      rds_protection               = "ENABLED"
      lambda_protection            = "ENABLED"
      eks_audit_logs               = "ENABLED"
      ebs_malware_protection       = "ENABLED"
    }
    "us-east-1" = {
      s3_protection                 = "ENABLED"
      runtime_monitoring            = "ENABLED"
      ecs_fargate_agent_management = "ENABLED"
      rds_protection               = "ENABLED"
      lambda_protection            = "ENABLED"
      eks_audit_logs               = "ENABLED"
      ebs_malware_protection       = "DISABLED"
    }
  }

  # StackSets操作設定
  max_concurrent_count    = 10
  failure_tolerance_count = 2
  region_concurrency_type = "PARALLEL"
}
```

## 入力変数

| 変数名 | 型 | デフォルト | 説明 |
|--------|-----|-----------|------|
| `name_prefix` | string | `""` | リソース名のプレフィックス |
| `tags` | map(string) | `{}` | リソースに適用するタグ |
| `target_regions` | list(string) | 全リージョン | GuardDutyを有効化するリージョンのリスト |
| `default_s3_protection` | string | `"DISABLED"` | S3保護のデフォルト設定 |
| `default_runtime_monitoring` | string | `"DISABLED"` | ランタイム監視のデフォルト設定 |
| `default_ecs_fargate_agent_management` | string | `"DISABLED"` | ECS Fargateエージェント管理のデフォルト設定 |
| `default_rds_protection` | string | `"DISABLED"` | RDS保護のデフォルト設定 |
| `default_lambda_protection` | string | `"DISABLED"` | Lambda保護のデフォルト設定 |
| `default_eks_audit_logs` | string | `"DISABLED"` | EKS監査ログのデフォルト設定 |
| `default_ebs_malware_protection` | string | `"DISABLED"` | EBSマルウェア保護のデフォルト設定 |
| `finding_publishing_frequency` | string | `"SIX_HOURS"` | 検出結果の公開頻度 |
| `region_specific_config` | map(object) | `{}` | リージョン別のGuardDuty機能設定 |
| `max_concurrent_count` | number | `20` | StackSets操作の最大同時実行数 |
| `failure_tolerance_count` | number | `20` | StackSets操作の失敗許容数 |
| `region_concurrency_type` | string | `"PARALLEL"` | リージョン間の並行実行タイプ |

## 出力値

| 出力名 | 説明 |
|--------|------|
| `cloudformation_stack_set_id` | CloudFormation StackSetのID |
| `cloudformation_stack_set_name` | CloudFormation StackSetの名前 |
| `cloudformation_stack_set_arn` | CloudFormation StackSetのARN |
| `stack_set_administration_role_arn` | StackSets Administration RoleのARN |
| `stack_set_execution_role_arn` | StackSets Execution RoleのARN |
| `enabled_regions` | GuardDutyが有効化されたリージョンのリスト |
| `enabled_regions_count` | GuardDutyが有効化されたリージョンの数 |
| `guardduty_configuration` | GuardDutyの設定情報 |

## GuardDuty機能詳細

### 有効化可能な機能

1. **S3データイベント保護 (S3_DATA_EVENTS)**
   - S3バケット内のデータアクセスを監視
   - 不審なAPIアクティビティを検出

2. **EKS監査ログ (EKS_AUDIT_LOGS)**
   - Kubernetes APIサーバーの監査ログを分析
   - 不審なKubernetes活動を検出

3. **ランタイム監視 (RUNTIME_MONITORING)**
   - EC2インスタンスとコンテナの実行時脅威を検出
   - 追加設定でECS FargateとEC2エージェント管理を制御

4. **EBSマルウェア保護 (EBS_MALWARE_PROTECTION)**
   - EBSボリュームのマルウェアスキャンを実行
   - 感染したファイルを検出

5. **RDSログインイベント (RDS_LOGIN_EVENTS)**
   - データベースへの不審なログイン試行を検出
   - SQL認証の異常を監視

6. **Lambdaネットワークログ (LAMBDA_NETWORK_LOGS)**
   - Lambda関数のネットワーク活動を監視
   - 不審な外部通信を検出

## コスト考慮事項

- GuardDutyは使用量ベースの課金
- 全リージョンで有効化することで月額コストが発生
- 各機能の有効化により追加料金が発生する場合がある
- 詳細な料金情報は[AWS GuardDuty料金ページ](https://aws.amazon.com/guardduty/pricing/)を参照

## 注意事項

1. **IAMロール**
   - StackSets用のIAMロールが自動的に作成されます
   - 既存のロールと競合しないよう`name_prefix`を適切に設定してください

2. **リージョン制限**
   - 一部のAWSリージョンではGuardDutyの機能が制限される場合があります
   - 最新のサポート状況はAWSドキュメントを確認してください

3. **デプロイ時間**
   - 複数リージョンへの展開には時間がかかる場合があります
   - `max_concurrent_count`と`region_concurrency_type`で並行度を調整できます

4. **既存のGuardDuty**
   - 既にGuardDutyが有効化されているリージョンでは設定の更新のみ実行されます

## トラブルシューティング

### よくある問題

1. **IAM権限エラー**
   ```
   Error: AccessDenied: User is not authorized to perform: cloudformation:CreateStackSet
   ```
   - 実行ユーザーにCloudFormation StackSetsの権限が必要です

2. **リージョンサポートエラー**
   ```
   Error: GuardDuty is not supported in this region
   ```
   - 指定したリージョンでGuardDutyがサポートされているか確認してください

3. **StackSets展開エラー**
   - CloudFormationコンソールでStackSetsの状態を確認
   - エラーメッセージを確認して個別に対処

## 例: 段階的な展開

```hcl
# 段階1: 重要なリージョンでのみ有効化
module "guardduty_cfn_phase1" {
  source = "./modules/guardduty_cfn"

  name_prefix = "Phase1-"
  target_regions = [
    "ap-northeast-1",  # Tokyo
    "us-east-1"        # N. Virginia
  ]

  default_s3_protection      = "ENABLED"
  default_runtime_monitoring = "ENABLED"
}

# 段階2: 全リージョンへの展開
module "guardduty_cfn_phase2" {
  source = "./modules/guardduty_cfn"

  name_prefix = "Production-"
  # 全リージョンを指定
  target_regions = [
    # 全リージョンリスト
  ]

  # 全機能を有効化
  default_s3_protection                 = "ENABLED"
  default_runtime_monitoring            = "ENABLED"
  default_ecs_fargate_agent_management = "ENABLED"
  default_rds_protection               = "ENABLED"
  default_lambda_protection            = "ENABLED"
  default_eks_audit_logs               = "ENABLED"
}
```

## ライセンス

このモジュールはプロジェクトのライセンスに従います。 