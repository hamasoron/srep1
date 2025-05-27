#!/bin/bash

# エラー発生時にスクリプトを停止（最後まで実行させないエラーハンドリング）
set -e

# 環境変数の中身を確認（事前にECSのタスク定義のsecretsとenvironmentを設定しておく）
REQUIRED_VARS="DB_WRITER_HOST DB_PORT DB_MASTER_USERNAME DB_MASTER_PASSWORD DB_APP_USER DB_APP_PASSWORD DB_NAME"
for VAR in $REQUIRED_VARS; do
  if [ -z "${!VAR:-}" ]; then
    echo "[ERROR] Environment variable $VAR is not set."
    exit 1 ## 異常終了
  fi
done

# RDS/Aurora MySQLに接続できるか疎通確認（最大30回リトライ）
echo "[INFO] Waiting for database to be available..."
for i in $(seq 1 30); do
  if mysqladmin ping -h"$DB_WRITER_HOST" -P"$DB_PORT" -u"$DB_MASTER_USERNAME" -p"$DB_MASTER_PASSWORD" --silent; then
    echo "[INFO] Database is ready."
    break
  fi
  echo "[INFO] Waiting... ($i/30)"
  sleep 2
done

# 30回試してもRDS/Aurora MySQLに接続できなければ異常終了
if ! mysqladmin ping -h"$DB_WRITER_HOST" -P"$DB_PORT" -u"$DB_MASTER_USERNAME" -p"$DB_MASTER_PASSWORD" --silent; then
  echo "[ERROR] Database not reachable after 30 attempts."
  exit 1 ## 異常終了
fi

# ユーザー作成SQLの生成（ファイルがなければ作成）
SQL_FILE="/app/inituser.sql"
cat <<EOF > "$SQL_FILE"
DROP USER IF EXISTS '${DB_APP_USER}'@'%';
CREATE USER '${DB_APP_USER}'@'%' IDENTIFIED BY '${DB_APP_PASSWORD}';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP ON ${DB_NAME}.* TO '${DB_APP_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# RDS/Aurora MySQLに接続してSQLを実行
if ! mysql -h "$DB_WRITER_HOST" -P "$DB_PORT" -u "$DB_MASTER_USERNAME" -p"$DB_MASTER_PASSWORD" < "$SQL_FILE"; then
  echo "[ERROR]Failed to execute user creation SQL."
  exit 1 ## 異常終了
fi

# ユーザー作成成功メッセージ
echo "[INFO] User '${DB_APP_USER}' created (if not existed) and privileges granted successfully."