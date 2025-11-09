# よくある質問（FAQ）

SREP1プロジェクトに関するよくある質問と回答をまとめました。

---

## 📌 一般的な質問

### Q1. このプロジェクトの主な目的は何ですか？

**A:** このプロジェクトは、Terraform + GitHub ActionsによるAWS上でのWebアプリケーション基盤構築のポートフォリオです。実務で培ったIaC化・CI/CD構築・AWS移行のノウハウを凝縮しています。

---

### Q2. どのくらいの期間で構築できますか？

**A:** 
- **インフラ構築**: 初回は約20〜30分（Terraformによる自動化）
- **アプリデプロイ**: 約5〜10分（GitHub Actionsによる自動化）
- **合計**: 初めての方でも1〜2時間程度で完全な環境構築が可能

---

### Q3. AWSの無料枠で試せますか？

**A:** 
一部のサービスは無料枠対象ですが、以下は課金が発生します：

**課金対象:**
- Aurora MySQL: 約$50-70/月
- NAT Gateway: 約$35-40/月
- ALB: 約$20-25/月

**無料枠対象:**
- ECS Fargate: 月間タスク実行時間の一部
- CloudWatch Logs: 月間5GBまで

**推奨**: テスト後は必ずリソース削除することをお勧めします。

---

### Q4. 商用利用できますか？

**A:** 
このプロジェクトはポートフォリオ・学習目的で作成されています。商用利用する場合は、以下の対応が必要です：

- セキュリティ要件の再評価
- ログ保持期間の延長
- バックアップ戦略の強化
- 監視・アラート設定の追加
- 本番環境用のドメイン・証明書取得

---

## 🛠️ 技術的な質問

### Q5. なぜAurora Serverlessではなく、Auroraプロビジョンドインスタンスを使っているのですか？

**A:** 
以下の理由からプロビジョンドインスタンスを選択しました：

1. **予測可能なコスト**: 常時稼働のアプリケーションでは、プロビジョンドの方がコスト効率が良い
2. **パフォーマンス**: コールドスタートがない
3. **学習目的**: 実務でよく使われる構成の理解

**Aurora Serverless v2が適しているケース:**
- トラフィックの変動が大きい
- 断続的なワークロード
- 開発・テスト環境（費用削減）

---

### Q6. なぜECS Fargateを選んだのですか？EC2やLambdaではダメですか？

**A:** 
各サービスの比較：

| サービス | メリット | デメリット | 適用ケース |
|---------|---------|-----------|----------|
| **ECS Fargate** | サーバー管理不要、スケーラブル、コンテナ実行 | EC2より割高 | **今回のケース** |
| **EC2** | コスト効率（大規模） | サーバー管理必要 | 大規模・長期稼働 |
| **Lambda** | 完全サーバーレス、従量課金 | 15分制限、コールドスタート | イベント駆動処理 |

Fargateを選んだ理由:
- ✅ サーバー管理不要
- ✅ コンテナ技術の実践
- ✅ CI/CDとの相性が良い
- ✅ 実務での採用事例が多い

---

### Q7. Terraformモジュールはどう設計すべきですか？

**A:** 
本プロジェクトでは以下の設計思想を採用しています：

**1. 単一責任の原則**
- 1モジュール = 1リソースタイプ（VPC、ECS、RDSなど）

**2. 再利用性**
- 環境（dev/stg/prod）を跨いで使用可能
- 変数でカスタマイズ可能

**3. 依存関係の明確化**
- 出力値（outputs）で他モジュールに値を渡す
- `depends_on`で明示的に依存関係を定義

**4. ドキュメント化**
- 各モジュールにREADME.md
- 変数に詳細な説明

---

### Q8. CI/CDパイプラインでIAMユーザーではなく、OIDCを使う理由は？

**A:** 
OIDCの利点：

1. **セキュリティ向上**
   - アクセスキー不要 → 漏洩リスクゼロ
   - 一時的な認証情報（15分〜1時間）

2. **運用効率**
   - キーローテーション不要
   - GitHub Secretsの管理が簡単

3. **細かいアクセス制御**
   - リポジトリ・ブランチ単位で制御可能

**設定例:**
```json
{
  "Condition": {
    "StringLike": {
      "token.actions.githubusercontent.com:sub": "repo:your-username/srep1:*"
    }
  }
}
```

---

### Q9. Secrets Managerのローテーション周期は30日が適切ですか？

**A:** 
30日は業界標準ですが、要件に応じて調整可能です：

| 周期 | 適用ケース |
|------|-----------|
| **7日** | 高セキュリティ要件（金融、医療） |
| **30日** | 一般的な本番環境（推奨） |
| **90日** | 開発・テスト環境 |

本プロジェクトでは30日を採用していますが、`terraform/modules/lambda/variables.tf`で変更可能です。

---

### Q10. マルチリージョン構成にできますか？

**A:** 
可能ですが、以下の考慮が必要です：

**必要な変更:**
1. **Route53によるDNSルーティング**
   - Latency-based routing
   - Geolocation routing

2. **Aurora Global Database**
   - プライマリ（ap-northeast-1）
   - セカンダリ（us-east-1など）
   - RPO: 1秒、RTO: 1分

3. **コスト増加**
   - リソースが2倍
   - データ転送料金

**実装の複雑さ**: 中〜高

---

## 🔧 運用に関する質問

### Q11. 本番環境での推奨設定は？

**A:** 
本番環境では以下の設定を推奨します：

```hcl
# terraform/environments/prod/terraform.tfvars

# 高可用性構成
use_all_azs_for_aurora = true  # 3AZ構成

nat_gateway_list = [
  { az = "1a", enabled = true },
  { az = "1c", enabled = true },
  { az = "1d", enabled = true },
]

# バックアップ
backup_retention_period = 7  # 7日間保持

# ログ保持
log_retention_days = 30  # 30日間保持

# モニタリング
enable_enhanced_monitoring = true
monitoring_interval = 60  # 1分間隔
```

**追加設定:**
- WAFルールの強化
- GuardDutyの有効化
- CloudTrailの有効化
- 定期的なセキュリティ監査

---

### Q12. デプロイの失敗時、どうすればいいですか？

**A:** 
デプロイ失敗時の対処手順：

**1. GitHub Actionsログ確認**
```
GitHub リポジトリ > Actions > 失敗したワークフロー > ログ確認
```

**2. ECSタスクの状態確認**
```bash
aws ecs describe-tasks \
  --cluster srep1-prod-ecs-cluster \
  --tasks $(aws ecs list-tasks --cluster srep1-prod-ecs-cluster --query 'taskArns[0]' --output text)
```

**3. CloudWatch Logsで詳細確認**
```bash
aws logs tail /aws/ecs/srep1-prod-api-python --follow
```

**4. ロールバック**
```bash
# 前のバージョンのイメージタグを確認
aws ecr list-images --repository-name srep1-prod-api-python-repo

# 手動でタスク定義を更新
aws ecs update-service \
  --cluster srep1-prod-ecs-cluster \
  --service srep1-prod-api-python-service \
  --task-definition srep1-prod-api-python-taskdef:previous-revision
```

---

### Q13. データベースのバックアップから復元するには？

**A:** 
Aurora MySQLの復元手順：

**自動バックアップからの復元:**
```bash
# スナップショット一覧取得
aws rds describe-db-cluster-snapshots \
  --db-cluster-identifier srep1-prod-aurora-cluster

# 復元
aws rds restore-db-cluster-from-snapshot \
  --db-cluster-identifier srep1-prod-aurora-cluster-restored \
  --snapshot-identifier <snapshot-id> \
  --engine aurora-mysql
```

**Point-in-Time Recovery (PITR):**
```bash
aws rds restore-db-cluster-to-point-in-time \
  --source-db-cluster-identifier srep1-prod-aurora-cluster \
  --db-cluster-identifier srep1-prod-aurora-cluster-restored \
  --restore-to-time 2025-01-01T12:00:00Z
```

---

### Q14. コストを削減する方法は？

**A:** 
コスト削減のベストプラクティス：

**1. 環境別最適化**
```hcl
# dev環境: 最小構成
use_all_azs_for_aurora = false
nat_gateway_list = [
  { az = "1a", enabled = true },
  { az = "1c", enabled = false },
]
```

**2. 非稼働時の停止**
```bash
# 夜間・週末停止（dev環境）
aws ecs update-service \
  --cluster srep1-dev-ecs-cluster \
  --service srep1-dev-api-python-service \
  --desired-count 0
```

**3. Fargate Spot活用**（dev/stg）
```hcl
capacity_provider_strategy = [
  {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
    base              = 0
  }
]
```

**4. CloudWatch Logsの保持期間短縮**
```hcl
log_retention_days = 7  # dev環境
```

**5. 不要なリソースの削除**
- 使用していないECRイメージ
- 古いスナップショット
- テスト用のリソース

---

## 🔒 セキュリティに関する質問

### Q15. このプロジェクトはセキュアですか？

**A:** 
本プロジェクトは以下のセキュリティ対策を実装しています：

**実装済み:**
- ✅ WAF（SQLインジェクション、XSS対策）
- ✅ Private Subnet（ECS、RDS）
- ✅ セキュリティグループ（最小権限）
- ✅ Secrets Manager（認証情報保護）
- ✅ GuardDuty（脅威検知）
- ✅ CloudTrail（監査ログ）
- ✅ IAM Access Analyzer

**本番環境での追加推奨:**
- 📋 DDoS対策（AWS Shield Advanced）
- 📋 侵入検知（Amazon Detective）
- 📋 定期的な脆弱性スキャン
- 📋 セキュリティ監査（第三者）
- 📋 コンプライアンス対応（PCI-DSS、SOC2など）

---

### Q16. GitHubにTerraform Stateをコミットしていいですか？

**A:** 
**絶対にダメです！**

理由：
- ❌ 機密情報が含まれる（パスワード、ARNなど）
- ❌ GitHubに永続的に残る
- ❌ セキュリティリスク

**正しい方法:**
- ✅ S3バックエンドを使用
- ✅ バージョニング有効化
- ✅ 暗号化有効化
- ✅ アクセス制御

本プロジェクトでは`.gitignore`で`*.tfstate`を除外しています。

---

## 📊 パフォーマンスに関する質問

### Q17. レスポンスタイムが遅い場合の対処は？

**A:** 
パフォーマンス改善のチェックリスト：

**1. CloudWatch メトリクス確認**
- ECS CPU/メモリ使用率
- RDS CPU/接続数
- ALBレスポンスタイム

**2. ボトルネック特定**
```bash
# ALBメトリクス
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --dimensions Name=LoadBalancer,Value=<alb-name> \
  --start-time 2025-01-01T00:00:00Z \
  --end-time 2025-01-01T23:59:59Z \
  --period 3600 \
  --statistics Average
```

**3. 改善施策**
- ECSタスクのスケールアウト
- Auroraインスタンスタイプ変更
- データベースインデックス追加
- アプリケーションコードの最適化

---

### Q18. どのくらいのトラフィックに対応できますか？

**A:** 
現在の構成での処理能力目安：

**ECS Fargate（2タスク）:**
- 約500〜1000リクエスト/分
- Auto Scalingで10タスクまで拡張可能

**Aurora MySQL（db.t4g.medium）:**
- 約100〜200接続
- Read Replicaで読み取り性能向上

**ALB:**
- 数千〜数万リクエスト/秒（自動スケール）

**大規模トラフィック対応:**
- ECSタスク数増加
- Auroraインスタンスタイプ変更（db.r6g.large等）
- CloudFront追加（静的コンテンツキャッシュ）

---

## 💡 その他

### Q19. このプロジェクトで学べることは？

**A:** 
以下のスキルを習得できます：

**インフラ:**
- Terraformによるインフラコード化
- AWSマルチAZ構成設計
- セキュリティベストプラクティス
- 監視・ロギング設計

**CI/CD:**
- GitHub Actionsによる自動化
- OIDC認証の実装
- コンテナイメージ管理

**運用:**
- 高可用性設計
- コスト最適化
- トラブルシューティング

---

### Q20. 追加の質問がある場合は？

**A:** 
以下の方法でお問い合わせください：

1. **GitHubイシュー**: 技術的な質問・バグ報告
2. **メール**: プライベートな質問
3. **ドキュメント参照**:
   - [README.md](./README.md) - プロジェクト概要
   - [SETUP.md](./SETUP.md) - セットアップガイド
   - [ARCHITECTURE.md](./ARCHITECTURE.md) - アーキテクチャ詳細

---

**このFAQで解決しない問題がありましたら、お気軽にお問い合わせください！**

