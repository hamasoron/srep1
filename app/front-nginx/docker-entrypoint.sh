#!/bin/bash

# エラー発生時にシェルスクリプトを停止（最後まで実行させないエラーハンドリング）
set -e

# S3から設定を取得（バケットにdefault.confがあるか確認, その後/etc/nginx/conf.d/default.confにコピー）
## s3から読み込むパターン, 更新のたびに再ビルドが不要, 設定ファイルの変更が多い場合はオススメ, S3用のタスクロールを付与
# if aws s3 ls "s3://hamasoron/front/front-nginx/default.conf" > /dev/null 2>&1; then
#     aws s3 cp s3://hamasoron/front/front-nginx/default.conf /etc/nginx/conf.d/default.conf
# fi
envsubst '${SERVICE_DISCOVERY_NAME} ${NAMESPACE_NAME}' \
  < /etc/nginx/templates/default_template.conf \
  > /etc/nginx/conf.d/default.conf

# シェルスクリプトの中で引数として渡されたコマンドを実行し、そのプロセスを置き換える （entrypointのscriptでは必須の記述）
exec "$@"

# Windowsで作成している場合は以下の手順で改行コードを確認し修正すること
## cat -A docker-entrypoint.sh
## vi docker-entrypoint.sh
## :set ff?
## :set ff=unix
## :set ff?
## :wq
## cat -A docker-entrypoint.sh

