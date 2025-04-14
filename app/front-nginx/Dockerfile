# ベースイメージの取得
FROM public.ecr.aws/amazonlinux/amazonlinux:2023 

# パッケージのアップデートとインストール
RUN dnf -y update && \
    dnf -y install nginx && \
    dnf -y install awscli && \
    rm -rf /var/cache/dnf && \
    dnf clean all

# 作業ディレクトリの指定（なければ自動作成）
WORKDIR /usr/share/nginx/html

# ローカルのdefault.confをコンテナの/etc/nginx/conf.d/にコピー
COPY default.conf /etc/nginx/conf.d/

# 静的ファイルをコンテナの/usr/share/nginx/html/にコピー
COPY index.html script.js style.css /usr/share/nginx/html/

# コンテナの待ち受けポートを80とする
EXPOSE 80

# （コンテナの起動時に）nginxをフォアグラウンドで起動
CMD ["nginx", "-g", "daemon off;"]
