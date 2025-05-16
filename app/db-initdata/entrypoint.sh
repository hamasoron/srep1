#!/bin/bash

# エラー発生時にシェルスクリプトを停止（最後まで実行させないエラーハンドリング）
set -e

# 初期化プロセスの開始
echo "[INFO] Starting DB initdata process..."

# 必須環境変数の存在確認
REQUIRED_VARS="DB_HOST DB_PORT DB_NAME DB_USERNAME DB_PASSWORD"
for VAR in $REQUIRED_VARS; do
  if [ -z "$(eval echo \$$VAR)" ]; then
    echo "[ERROR] Environment variable $VAR is not set."
    exit 1
  fi
done

# RDS/Auroraの起動待機（最大30回リトライ）
echo "[INFO] Waiting for database to be available..."
for i in $(seq 1 30); do
  if mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USERNAME" -p"$DB_PASSWORD" --silent; then
    echo "[INFO] Database is ready."
    break
  fi
  echo "[INFO] Waiting... ($i/30)"
  sleep 2
done

# 初期化データSQLの実行
echo "[INFO] Executing initdata.sql..."
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" < /app/initdata.sql

echo "[INFO] DB initdata completed successfully."