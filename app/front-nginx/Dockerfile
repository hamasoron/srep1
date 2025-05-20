# FROM命令:ベースイメージを指定
FROM public.ecr.aws/amazonlinux/amazonlinux:2023 

# RUN命令:コマンドを実行（パッケージのアップデートとインストール）
RUN dnf -y update && \
    dnf -y install nginx && \
    dnf -y install awscli && \
    dnf -y install gettext && \
    rm -rf /var/cache/dnf && \
    dnf clean all

# WORKDIR命令:作業ディレクトリを指定（なければ自動作成）
WORKDIR /usr/share/nginx/html

# RUN命令:コマンドを実行（ディレクトリを再帰的に作成）
RUN mkdir -p /etc/nginx/templates

# COPY命令:ローカルのファイルをコンテナにコピー
COPY default_template.conf /etc/nginx/templates/default_template.conf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# RUN命令:コマンドを実行（スクリプトの実行権限の付与）
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# ENTRYPOINT命令:（コンテナ起動時に）毎回スクリプトを実行
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# COPY命令:ローカルのファイルをコンテナにコピー
COPY index.html script.js style.css /usr/share/nginx/html/

# EXPOSE命令:コンテナの待ち受けポートを指定
EXPOSE 80

# CMD命令:（コンテナ起動時に）コマンドを実行（nginxをフォアグラウンドで起動）
CMD ["nginx", "-g", "daemon off;"]
