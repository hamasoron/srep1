# ベースイメージの取得
FROM public.ecr.aws/amazonlinux/amazonlinux:2023

# pythonをインストール
RUN dnf -y update && \
    dnf -y install python3 && \
    dnf -y install pip && \
    dnf -y install awscli && \
    rm -rf /var/cache/dnf && \
    dnf clean all
    
# 作業ディレクトリ
WORKDIR /app

# 依存ライブラリのインストール
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# アプリコードをコピー
COPY . /app/

# デフォルトの環境変数を設定（実行時に上書き可能）
ENV DB_USERNAME="" \
    DB_PASSWORD="" \
    DB_SERVERNAME="" \
    DB_PORT="3306" \
    DB_NAME="hamasorondb" \
    FLASK_ENV="production" \
    PYTHONUNBUFFERED="1"

# Flaskを実行するポート(Goのコードと同じく 8080 に合わせる場合)
EXPOSE 8080

# アプリ起動コマンド
CMD [ "python3", "app.py" ]
