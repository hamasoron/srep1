# FROM命令:ベースイメージを指定
FROM public.ecr.aws/amazonlinux/amazonlinux:2023

# RUN命令:コマンドを実行（パッケージのアップデートとインストール）
RUN dnf -y update && \
    dnf -y install python3 && \
    dnf -y install pip && \
    dnf -y install awscli && \
    rm -rf /var/cache/dnf && \
    dnf clean all

# WORKDIR命令:作業ディレクトリを指定（なければ自動作成）
WORKDIR /app

# COPY命令:ローカルのファイルをコンテナにコピー
COPY requirements.txt /app/

# RUN命令:コマンドを実行（依存ライブラリのインストール）
RUN pip install --no-cache-dir -r requirements.txt

# COPY命令:ローカルのファイルをコンテナにコピー
COPY app.py /app/

# デフォルトの環境変数を設定（タスク定義のenvironmentセクションで記述すると実行時に上書きされる）
# ENV DB_USERNAME="hamasoron" \
#     DB_PASSWORD="i7V956YP" \
#     DB_SERVERNAME="srep1-dev-aurora-cluster.cluster-cfaa8ocau40c.ap-northeast-1.rds.amazonaws.com" \
#     DB_PORT="3306" \
#     DB_NAME="hamasorondb" \
#     FLASK_DEBUG="0" \
#     PYTHONUNBUFFERED="1" \
#     WORKERS="2"

# EXPOSE命令:コンテナの待ち受けポートを指定
EXPOSE 8080

# CMD命令:（コンテナ起動時に）コマンドを実行（Gunicornの起動コマンド）
## Gunicorn（グニコーン）の起動コマンド
## --bind: ホストとポートを指定
## --workers: ワーカープロセス数（通常はCPUコア数 * 2 + 1 が推奨）
## --timeout: リクエストタイムアウト時間（秒）
## --access-logfile: アクセスログの出力先（- は標準出力）
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--timeout", "120", "--access-logfile", "-", "app:app"]