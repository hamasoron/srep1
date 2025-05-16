#!/bin/bash

# エラー発生時にスクリプトを停止（最後まで実行させないエラーハンドリング）
# エラー発生時に行番号を表示して異常終了
set -e
trap 'echo "[ERROR] Script failed at line $LINENO"; exit 1' ERR

# 初期データ投入プロセスの開始
echo "[INFO] Starting DB initdata process..."

# 環境変数の中身を確認
REQUIRED_VARS="DB_HOST DB_PORT DB_NAME DB_USERNAME DB_PASSWORD"
for VAR in $REQUIRED_VARS; do
  if [ -z "$(eval echo \$$VAR)" ]; then
    echo "[ERROR] Environment variable $VAR is not set."
    exit 1 ## 異常終了
  fi
done

# 初期データ投入SQLファイルの存在確認
if [ ! -f /app/initdata.sql ]; then
  echo "[ERROR] /app/initdata.sql not found."
  hamasoron
  exit 1 ## 異常終了
fi

# RDS/Auroraに接続できるかどうか疎通確認（最大30回リトライ）
echo "[INFO] Waiting for database to be available..."
for i in $(seq 1 30); do
  if mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USERNAME" -p"$DB_PASSWORD" --silent; then
    echo "[INFO] Database is ready."
    break
  fi
  echo "[INFO] Waiting... ($i/30)"
  sleep 2
done

# 30回試してもRDS/Auroraに接続できなかった場合は異常終了
if ! mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USERNAME" -p"$DB_PASSWORD" --silent; then
  echo "[ERROR] Database not reachable after 30 attempts."
  exit 1 ## 異常終了
fi

# 初期データ投入SQLの実行
echo "[INFO] Executing initdata.sql..."
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" < /app/initdata.sql

# 初期データ投入完了
echo "[INFO] DB initdata completed successfully."