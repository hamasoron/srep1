# ベースイメージの取得
FROM public.ecr.aws/amazonlinux/amazonlinux:2023 

# nginxをインストール
RUN dnf -y update && \
    dnf -y install nginx && \
    dnf -y install awscli && \
    rm -rf /var/cache/dnf && \
    dnf clean all

# 作業ディレクトリを設定
WORKDIR /usr/share/nginx/html

# ローカルのdefault.confをコンテナの/etc/nginx/conf.d/にコピー
COPY default.conf /etc/nginx/conf.d/

# 静的ファイルをコピー
COPY index.html script.js style.css /usr/share/nginx/html/

# エントリポイントスクリプトをコピーして実行権限を付与
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# コンテナの待ち受けポート 
EXPOSE 80

# エントリポイントを設定
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# コマンド
CMD ["nginx", "-g", "daemon off;"]
