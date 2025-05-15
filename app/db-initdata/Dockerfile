# ベースイメージの取得
FROM public.ecr.aws/amazonlinux/amazonlinux:2023

# パッケージのアップデートとインストール
RUN dnf -y update && \
    dnf -y install https://dev.mysql.com/get/mysql84-community-release-el9-1.noarch.rpm && \
    dnf -y install mysql-community-client && \
    dnf -y install awscli && \
    dnf clean all

# 作業ディレクトリ（なければ自動作成）
WORKDIR /app

# ローカルの初期化スクリプトをコンテナの/app/にコピー
COPY init.sql /app/

# デフォルトの環境変数（タスク定義のenvironmentセクションで記述すると実行時に上書きされる）
# ENV DB_HOST="srep1-dev-aurora-cluster.cluster-cfaa8ocau40c.ap-northeast-1.rds.amazonaws.com"
# ENV DB_PORT="3306"
# ENV DB_NAME="hamasorondb"
# ENV DB_USER="hamasoron"
# ENV DB_PASSWORD="i7V956YP"

# （コンテナ起動時に）初期化スクリプトを実行
CMD ["sh", "-c", "mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME < /app/init.sql"]