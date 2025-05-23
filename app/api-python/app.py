# ライブラリのインポート
## 標準ライブラリ（プリインストール）
import os
## 外部ライブラリ（pip install -r requirements.txtで一括インストール）
import mysql.connector
from flask import Flask, request, make_response, jsonify
from dotenv import load_dotenv
import logging

# ロギングの設定
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# .envから環境変数を読み込み
load_dotenv()

app = Flask(__name__)

def set_cors_headers(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    return response

@app.route("/", methods=["GET", "OPTIONS"])
def apitest_handler():
    if request.method == "OPTIONS":
        return set_cors_headers(make_response(""))
    # テキストレスポンスを生成
    text = "API接続テストが成功しました"
    response = make_response(text)
    response.mimetype = "text/plain"
    return set_cors_headers(response)

@app.route("/health", methods=["GET"])
def health_check():
    """
    ECS Fargateのヘルスチェック用エンドポイント
    """
    return jsonify({"status": "ok"})

@app.route("/dbtest", methods=["GET", "OPTIONS"])
def dbtest_handler():
    if request.method == "OPTIONS":
        return set_cors_headers(make_response(""))
    try:
        logger.info("DB test was executed")
        count = database_test()
        text = f"DB接続テストが成功しました（aws_certifications の件数：{count}）"
        response = make_response(text)
        response.mimetype = "text/plain"
        return set_cors_headers(response)
    except Exception as e:
        logger.error(f"Database connection error: {str(e)}")
        text = f"Database error: {str(e)}"
        response = make_response(text, 500)
        response.mimetype = "text/plain"
        return set_cors_headers(response)

def database_test():
    # 環境変数からDB接続情報を取得
    username   = os.getenv("DB_APP_USERNAME")
    password   = os.getenv("DB_APP_PASSWORD")
    servername = os.getenv("DB_READER_HOST")
    port       = os.getenv("DB_PORT")
    dbname     = os.getenv("DB_NAME")
    
    # 接続情報をログに記録（パスワードを除く）
    logger.info(f"Database connection: {username}@{servername}:{port}/{dbname}")
    
    # 接続情報の検証
    if not servername:
        raise ValueError("Environment variable DB_READER_HOST is not set")
    if not username:
        raise ValueError("Environment variable DB_APP_USERNAME is not set")
    if not password:
        raise ValueError("Environment variable DB_APP_PASSWORD is not set")

    connection = None
    cursor = None
    try:
        # コネクションの作成
        connection = mysql.connector.connect(
            host=servername,
            user=username,
            password=password,
            database=dbname,
            port=int(port)
        )
        cursor = connection.cursor()
        
        # クエリの実行
        query = "SELECT COUNT(*) AS count FROM aws_certifications"
        cursor.execute(query)
        result = cursor.fetchone()
        count = result[0] if result else 0
        return count
    except mysql.connector.Error as err:
        logger.error(f"MySQL error: {err}")
        raise
    finally:
        # 必ずリソースを解放
        if cursor:
            cursor.close()
        if connection and connection.is_connected():
            connection.close()
            logger.info("Database connection closed")

# Flaskの開発サーバーとして実行する場合のエントリポイント
if __name__ == "__main__":
    port = int(os.getenv("PORT", "8080"))
    debug_mode = os.getenv("FLASK_DEBUG", "0") == "1"
    logger.info(f"Starting Flask server: port={port}, debug={debug_mode}")
    app.run(host="0.0.0.0", port=port, debug=debug_mode)