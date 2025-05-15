# ベースイメージの取得
FROM public.ecr.aws/amazonlinux/amazonlinux:2023 

# パッケージのアップデートとインストール
RUN dnf -y update && \
    dnf -y install nginx && \
    dnf -y install awscli && \
    dnf -y install gettext && \
    rm -rf /var/cache/dnf && \
    dnf clean all

# 作業ディレクトリの指定（なければ自動作成）
WORKDIR /usr/share/nginx/html

# テンプレートファイルをコンテナの/etc/nginx/templates/にコピー
RUN mkdir -p /etc/nginx/templates
COPY default_template.conf /etc/nginx/templates/

# 環境ごとのdefault.confを作成する起動スクリプトを追加
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# （コンテナの起動時に）毎回起動スクリプトを実行
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# 静的ファイルをコンテナの/usr/share/nginx/html/にコピー
COPY index.html script.js style.css /usr/share/nginx/html/

# コンテナの待ち受けポートを80とする
EXPOSE 80

# （コンテナの起動時に）nginxをフォアグラウンドで起動
CMD ["nginx", "-g", "daemon off;"]
