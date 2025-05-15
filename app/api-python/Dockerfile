# ベースイメージの取得
FROM public.ecr.aws/amazonlinux/amazonlinux:2023

# パッケージのアップデートとインストール
RUN dnf -y update && \
    dnf -y install python3 && \
    dnf -y install pip && \
    dnf -y install awscli && \
    rm -rf /var/cache/dnf && \
    dnf clean all

# 作業ディレクトリの指定（なければ自動作成）
WORKDIR /app

# ローカルの依存ライブラリのファイルをコンテナの/app/にコピー
COPY requirements.txt /app/

# 依存ライブラリのインストール（キャッシュしないかつrequirements.txtの内容をまとめてインストール）
RUN pip install --no-cache-dir -r requirements.txt

# ローカルのアプリコードをコンテナの/app/にコピー
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

# コンテナの待ち受けポートを8080とする
EXPOSE 8080

# Gunicorn（グニコーン）の起動コマンド
# --bind: ホストとポートを指定
# --workers: ワーカープロセス数（通常はCPUコア数 * 2 + 1 が推奨）
# --timeout: リクエストタイムアウト時間（秒）
# --access-logfile: アクセスログの出力先（- は標準出力）
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--timeout", "120", "--access-logfile", "-", "app:app"]