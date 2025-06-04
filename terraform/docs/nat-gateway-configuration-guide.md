# NATゲートウェイ設定ガイド

VPCモジュールでは、企業のニーズに応じてNATゲートウェイの数を柔軟に制御できます。`terraform.tfvars`ファイルでの設定をサポートし、既存のSubnetやRoutetableと同様に動的な設定が可能です。

## 🎯 設定方法の概要

### 1. terraform.tfvarsでの設定（推奨）
```hcl
nat_gateway_config = {
  strategy = "auto"  # auto, manual, custom
  # その他のオプション...
}
```

### 2. 従来の変数での設定（後方互換性）
```hcl
# モジュール呼び出し時
enable_auto_nat_calculation = true
nat_gateway_count = 2
use_all_azs_for_nat = true
```

## 📊 設定の優先順位

設定は以下の優先順位で適用されます：

1. **terraform.tfvars（manual）** - `manual_count`で明示指定
2. **従来変数** - `nat_gateway_count`での指定
3. **terraform.tfvars（strategy）** - `auto`または`custom`戦略
4. **従来の自動計算** - 後方互換性のための計算

## 🛠️ 設定パターン詳細

### パターン1: 自動計算（推奨）

環境とAZ数に基づいて自動でNATゲートウェイ数を決定します。

```hcl
# terraform.tfvars
nat_gateway_config = {
  strategy            = "auto"
  use_all_azs_for_nat = true  # 3AZ環境: true=3個, false=2個
}
```

**自動計算ルール:**
- **dev環境**: 最大1個（コスト重視）
- **stg/prod環境**: 
  - 2AZ: 2個
  - 3AZ: `use_all_azs_for_nat`に応じて2個または3個

### パターン2: 手動指定

特定の数を明示的に指定します。

```hcl
# terraform.tfvars
nat_gateway_config = {
  strategy     = "manual"
  manual_count = 2  # 強制的に2個作成
}
```

### パターン3: カスタムマッピング

環境ごとに詳細なルールを定義します。

```hcl
# terraform.tfvars
nat_gateway_config = {
  strategy = "custom"
  count_per_environment = {
    dev = {
      "2az" = 0    # 開発環境：NATなし（コスト削減）
      "3az" = 1    # 開発環境：最低限の1個
    }
    stg = {
      "2az" = 1    # ステージング：コスト重視
      "3az" = 2    # ステージング：中程度の可用性
    }
    prod = {
      "2az" = 2    # 本番：高可用性
      "3az" = 3    # 本番：最高の可用性とパフォーマンス
    }
  }
}
```

## 📝 実用例

### 環境別設定ファイル

**dev.tfvars**
```hcl
environment_name = "dev"
nat_gateway_config = {
  strategy = "auto"
  use_all_azs_for_nat = false  # コスト重視
}
```

**prod.tfvars**
```hcl
environment_name = "prod"
nat_gateway_config = {
  strategy = "auto"
  use_all_azs_for_nat = true  # パフォーマンス重視
}
```

### 特殊要件への対応

**災害対策重視の設定**
```hcl
nat_gateway_config = {
  strategy = "custom"
  count_per_environment = {
    prod = {
      "3az" = 3  # 全AZに配置で最高の可用性
    }
  }
}
```

**コスト最適化設定**
```hcl
nat_gateway_config = {
  strategy = "custom"
  count_per_environment = {
    dev = { "2az" = 0, "3az" = 0 }  # 開発環境はNATなし
    stg = { "2az" = 1, "3az" = 1 }  # ステージングは最小限
    prod = { "2az" = 2, "3az" = 2 } # 本番は2個固定
  }
}
```

## 🔍 デバッグと確認

### 設定の確認方法

```bash
terraform plan
terraform output nat_configuration_info
```

### 出力例
```json
{
  "config_source": "terraform.tfvars(auto)",
  "strategy": "auto",
  "final_nat_count": 3,
  "lookup_key": "prod-3az-true",
  "tfvars_config": {
    "strategy": "auto",
    "use_all_azs_for_nat": true
  }
}
```

## ⚠️ 注意点

1. **protectedサブネットなしの場合**: NATゲートウェイは作成されません
2. **互換性**: 既存の変数設定も引き続き動作します
3. **コスト**: NATゲートウェイは従量課金なので、必要以上に作成しないよう注意
4. **可用性**: 単一NATの場合、そのAZで障害が発生すると影響を受けます

## 🚀 移行ガイド

### 既存設定からの移行

**従来の設定:**
```hcl
enable_auto_nat_calculation = true
use_all_azs_for_nat = true
```

**新しい設定:**
```hcl
nat_gateway_config = {
  strategy = "auto"
  use_all_azs_for_nat = true
}
```

段階的移行が可能で、既存の設定はそのまま動作します。 