#!/bin/bash

# エラー発生時にスクリプトを停止（最後まで実行させないエラーハンドリング）
# エラー発生時に行番号を表示して異常終了
set -e
trap 'echo "[ERROR] Script failed at line $LINENO"; exit 1' ERR

# 環境変数を展開してdefault.confを作成
if ! envsubst '${SERVICE_DISCOVERY_NAME} ${NAMESPACE_NAME}' \
  < /etc/nginx/templates/default_template.conf \
  > /etc/nginx/conf.d/default.conf; then
  nontarofront
  echo "[ERROR] Failed to render default.conf"
  exit 1 ## 異常終了
fi


# ENTRYPOINTスクリプト内でCMDを実行 （ENTRYPOINT命令とCMD命令を併用する場合はコンテナの起動を安定させるために記述）
exec "$@"

# Windowsで作成している場合は以下の手順で改行コードを確認し修正すること
## cat -A docker-entrypoint.sh
## vi docker-entrypoint.sh
## :set ff?
## :set ff=unix
## :set ff?
## :wq
## cat -A docker-entrypoint.sh