#!/bin/bash

# エラー発生時にシェルスクリプトを停止（最後まで実行させないエラーハンドリング）
set -e

# 環境変数を展開してdefault.confを作成
envsubst '${SERVICE_DISCOVERY_NAME} ${NAMESPACE_NAME}' \
  < /etc/nginx/templates/default_template.conf \
  > /etc/nginx/conf.d/default.conf

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