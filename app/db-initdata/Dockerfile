# FROM命令:ベースイメージを指定
FROM public.ecr.aws/amazonlinux/amazonlinux:2023

# RUN命令:コマンドを実行（パッケージのアップデートとインストール）
RUN dnf -y update && \
    dnf -y install https://dev.mysql.com/get/mysql84-community-release-el9-1.noarch.rpm && \
    dnf -y install mysql-community-client && \
    dnf -y install awscli && \
    dnf clean all

# WORKDIR命令:作業ディレクトリを指定（なければ自動作成）
WORKDIR /app

# COPY命令:ローカルのファイルをコンテナにコピー
COPY initdata.sql /app/
COPY entrypoint.sh /app/

# RUN命令:コマンドを実行（シェルスクリプトの実行権限を付与）
RUN chmod +x /app/entrypoint.sh

# ENTRYPOINT命令:（コンテナ起動時に）毎回シェルスクリプトを実行
ENTRYPOINT [ "/app/entrypoint.sh" ]