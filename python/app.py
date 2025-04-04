# File: python/app.py
import os
import mysql.connector
from flask import Flask, request, make_response
from dotenv import load_dotenv

# .envから環境変数を読み込み
load_dotenv()

app = Flask(__name__)

def set_cors_headers(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    return response

@app.route("/", methods=["GET", "OPTIONS"])
def hello_handler():
    if request.method == "OPTIONS":
        return set_cors_headers(make_response(""))
    # テキストレスポンスを生成
    text = "API接続テストが成功しました"
    response = make_response(text)
    response.mimetype = "text/plain"
    return set_cors_headers(response)

@app.route("/dbtest", methods=["GET", "OPTIONS"])
def dbtest_handler():
    if request.method == "OPTIONS":
        return set_cors_headers(make_response(""))
    try:
        count = database_test()
        text = f"DB接続テストが成功しました（aws_certifications の件数：{count}）"
        response = make_response(text)
        response.mimetype = "text/plain"
        return set_cors_headers(response)
    except Exception as e:
        text = f"Database error: {str(e)}"
        response = make_response(text, 500)
        response.mimetype = "text/plain"
        return set_cors_headers(response)

def database_test():
    # 環境変数からDB接続情報を取得（DB_SERVERNAME にはMySQLコンテナの名前を指定）
    username   = os.getenv("DB_USERNAME", "")
    password   = os.getenv("DB_PASSWORD", "")
    servername = os.getenv("DB_SERVERNAME", "")
    port       = os.getenv("DB_PORT", "3306")
    dbname     = os.getenv("DB_NAME", "hamasorondb")

    connection = mysql.connector.connect(
        host=servername,
        user=username,
        password=password,
        database=dbname,
        port=port
    )
    cursor = connection.cursor()
    try:
        query = "SELECT COUNT(*) AS count FROM aws_certifications"
        cursor.execute(query)
        result = cursor.fetchone()
        count = result[0] if result else 0
        return count
    finally:
        cursor.close()
        connection.close()

if __name__ == "__main__":
    port = 8080
    print(f"Starting Flask server on port {port}")
    app.run(host="0.0.0.0", port=port)
