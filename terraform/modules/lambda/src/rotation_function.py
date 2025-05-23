# ライブラリのインポート
## 標準ライブラリ+AWS関連（boto3, botocore）の外部ライブラリ（プリインストール済み）
import os ### OS操作
import json ### JSON操作
import logging ### ログ出力
import time ### 時間操作
import random ### 乱数生成
import string ### 文字列操作
import boto3 ### AWS SDK
from botocore.exceptions import ClientError ### AWS SDKのエラーハンドリング
## 外部ライブラリ（pip install -r requirements.txtで一括インストール）
import pymysql ### MySQL接続用ライブラリ

# ログ出力の設定
logger = logging.getLogger() ## ログを取得するローカル変数の定義
logger.setLevel(logging.INFO) ## ログレベル（INFO）の設定

# 関数の定義
# エントリポイント（プログラムの開始点）の関数の定義
def lambda_handler(event, context): ## 関数と引数（event, context）の定義 
    """ローテーション関数のエントリポイント"""
    logger.info(f"Rotation event received: {json.dumps(event)}") ## ログ出力（Rotation event received: とeventの内容をJSON形式で出力）
    
    ## Step 1: ローカル変数の定義とイベント情報の取得
    arn = event['SecretId'] ### event内のSecretIdキー（SecretsManagerのシークレットのARN）の値を格納
    token = event['ClientRequestToken'] ### event内のClientRequestTokenキー（シークレットのバージョンID）の値を格納
    step = event['Step'] ### event内のStepキー（ローテーションのステップ）の値を格納。step:createSecret, setSecret, testSecret, finishSecret。
    service_client = boto3.client('secretsmanager') ### SecretsManager用のboto3クライアントを格納
    
    ## Step 2: SecretsManagerのローテーションの一連の処理をstep変数の中身に応じて実行
    """
    https://docs.aws.amazon.com/ja_jp/secretsmanager/latest/userguide/rotate-secrets_lambda.html
    上記ページより「ローテーションステップは、createSecret、setSecret、testSecret、finishSecret」に分けられる。
    それぞれのステップの処理は以下の関数で実行される。
    """
    try: ### try-except文でエラーハンドリング（エラー時の処理を記述）
        if step == 'createSecret': #### ステップの値がcreateSecretなら
            create_secret(service_client, arn, token) ##### create_secret関数を実行
        elif step == 'setSecret': #### ステップの値がsetSecretなら
            set_secret(service_client, arn, token) ##### set_secret関数を実行
        elif step == 'testSecret': #### ステップの値がtestSecretなら
            test_secret(service_client, arn, token) ##### test_secret関数を実行
        elif step == 'finishSecret': #### ステップの値がfinishSecretなら
            finish_secret(service_client, arn, token) ##### finish_secret関数を実行
        else: #### ステップの値が上記のいずれでもないなら
            logger.error(f"Unknown step: {step}") ##### ログ出力（Unknown step: とstep変数の中身を出力）
            raise ValueError(f"Unknown step: {step}") ##### エラーを挙げる（Unknown step: とstep変数の中身を出力）
            
        ### ローテーションの一連の処理が成功した場合
        logger.info(f"Successfully completed step {step} for secret {arn}") #### ログ出力（Successfully completed step とstep変数の中身とsecretのarnを出力）
        return {"statusCode": 200, "body": f"Step {step} completed successfully"} #### 戻り値（statusCode: 200, body: Step とstep変数の中身を出力）
        
    except Exception as e: ### ローテーションの一連の処理が失敗した場合
        logger.error(f"Error during rotation: {str(e)}") #### ログ出力（Error during rotation: とエラー内容を出力）
        raise #### エラーを挙げる

# ローテーション関数の定義
def create_secret(service_client, arn, token): ### 関数と引数（service_client, arn, token）の定義
    """新しいシークレットを作成 (createSecret ステップ)"""
    try: ### try-except文でエラーハンドリング（エラー時の処理を記述）
        # 既にPENDINGバージョンが存在する場合はスキップ
        try:
            get_secret(service_client, arn, token, 'AWSPENDING')
            logger.info("Secret already exists for AWSPENDING, skipping creation")
            return
        except ClientError as e:
            if e.response['Error']['Code'] != 'ResourceNotFoundException':
                raise
        
        current_secret = get_secret(service_client, arn, version_stage='AWSCURRENT') ### get_secret関数を実行し、戻り値をローカル変数current_secretに格納

        new_secret = create_new_secret_value(current_secret) ### create_new_secret_value関数を実行し、戻り値をローカル変数new_secretに格納
        
        service_client.put_secret_value( ### terraformでLambda関数と関連付けたSecretsManagerのシークレットの値を更新しローカル変数responseに格納
            SecretId=arn, ### シークレットのARNを格納
            ClientRequestToken=token, ### シークレットのバージョンIDを格納
            SecretString=json.dumps(new_secret), ### シークレットの値をJSON形式で格納
            VersionStages=['AWSPENDING'] ### シークレットのバージョンのステージングラベル（AWSPENDING or AWSCURRENT）を格納
        )
        logger.info("New secret created successfully")
    except Exception as e: ### エラーハンドリング（エラー時の処理を記述）
        logger.error(f"Error in create_secret: {str(e)}") #### ログ出力（Error in create_secret: とエラー内容を出力）
        raise #### エラーを挙げる

def set_secret(service_client, arn, token): ### 関数と引数（service_client, arn, token）の定義
    """新しいシークレット値をターゲットサービスに設定 (setSecret ステップ)"""
    try: ### try-except文でエラーハンドリング（エラー時の処理を記述）
        # 現在のシークレットと新しいシークレットを取得
        current_secret = get_secret(service_client, arn, version_stage='AWSCURRENT')
        pending_secret = get_secret(service_client, arn, token, 'AWSPENDING')
        
        # デバッグログ：シークレットの内容を確認
        logger.info(f"Current secret keys: {list(current_secret.keys())}")
        logger.info(f"Pending secret keys: {list(pending_secret.keys())}")
        
        # データベース接続情報を取得（以下の順番で取得）
        ## host: 現在のシークレット(current_secret) → なければ保留中のシークレット(pending_secret) → それもなければ環境変数(DB_LOTATION_WRITER_HOST)から取得
        ## port: current_secret→pending_secret→環境変数(DB_LOTATION_PORT)、なければ3306（デフォルト）を使用
        ## username, password: current_secretから取得
        ## new_password: pending_secretから取得（ローテーション時の新パスワード）
        host = current_secret.get('host') or pending_secret.get('host') or os.environ.get('DB_LOTATION_WRITER_HOST')
        port = int(current_secret.get('port', pending_secret.get('port', os.environ.get('DB_LOTATION_PORT', 3306))))
        username = current_secret.get('username')
        password = current_secret.get('password')
        new_password = pending_secret.get('password')
        
        # デバッグログ：取得した値を確認
        logger.info(f"Host: {host}, Port: {port}, Username: {username}")
        logger.info(f"Password exists: {bool(password)}, New password exists: {bool(new_password)}")
        
        # 入力値の検証
        if not all([host, username, password, new_password]):
            missing_fields = []
            if not host: missing_fields.append("host")
            if not username: missing_fields.append("username") 
            if not password: missing_fields.append("password")
            if not new_password: missing_fields.append("new_password")
            
            error_msg = f"必要な認証情報が不足しています。不足フィールド: {', '.join(missing_fields)}"
            logger.error(error_msg)
            raise ValueError(error_msg)
            
        logger.info(f"Updating database password for user {username}")
        # データベースに接続してパスワードを更新
        try:
            conn = pymysql.connect(
                host=host,
                port=port,
                user=username,
                password=password,
                connect_timeout=30,
                read_timeout=30,
                write_timeout=30
            )
            with conn.cursor() as cur:
                # パラメータ化クエリでSQLインジェクションを防ぐ
                # MySQL 8.0以降の構文でパスワードを更新
                alter_user_query = "ALTER USER %s@'%%' IDENTIFIED BY %s"
                cur.execute(alter_user_query, (username, new_password))
                cur.execute("FLUSH PRIVILEGES")
                logger.info(f"Successfully updated password for user {username}")
            conn.commit()
            conn.close()
        except pymysql.MySQLError as e:
            logger.error(f"Database error during password update: {str(e)}")
            raise
        logger.info("Secret updated in target system")
    except Exception as e: ### エラーハンドリング（エラー時の処理を記述）
        logger.error(f"Error in set_secret: {str(e)}") #### ログ出力（Error in set_secret: とエラー内容を出力）
        raise #### エラーを挙げる

def test_secret(service_client, arn, token): ### 関数と引数（service_client, arn, token）の定義
    """新しいシークレットのテスト (testSecret ステップ):このステップは最悪の場合不必要なステップ"""
    try: ### try-except文でエラーハンドリング（エラー時の処理を記述）
        pending_secret = get_secret(service_client, arn, token, 'AWSPENDING') ### get_secret関数を実行し、戻り値をローカル変数pending_secretに格納
        # 新しいパスワードでデータベースに接続してテスト（環境変数からも取得）
        host = pending_secret.get('host') or os.environ.get('DB_LOTATION_WRITER_HOST')
        port = int(pending_secret.get('port', os.environ.get('DB_LOTATION_PORT', 3306)))
        username = pending_secret.get('username')
        password = pending_secret.get('password')
        # 入力値の検証
        if not all([host, username, password]):
            raise ValueError("必要な認証情報が不足しています")
        logger.info(f"Testing connection with new password for user {username}")
        try:
            conn = pymysql.connect(
                host=host,
                port=port,
                user=username,
                password=password,
                connect_timeout=30,
                read_timeout=30,
                write_timeout=30
            )
            # 簡単なクエリでテスト
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
                result = cur.fetchone()
                if result[0] != 1:
                    raise Exception("Database connection test failed")
            conn.close()
            logger.info(f"Successfully connected with new password for user {username}")
        except pymysql.MySQLError as e:
            logger.error(f"Failed to connect with new password: {str(e)}")
            raise
        logger.info("Secret tested successfully")
    except Exception as e: ### エラーハンドリング（エラー時の処理を記述）
        logger.error(f"Error in test_secret: {str(e)}") #### ログ出力（Error in test_secret: とエラー内容を出力）
        raise

def finish_secret(service_client, arn, token): ### 関数と引数（service_client, arn, token）の定義
    """ローテーションプロセスの完了 (finishSecret ステップ)"""
    try: ### try-except文でエラーハンドリング（エラー時の処理を記述）
        # 現在のバージョンIDを取得
        current_version_id = get_current_version(service_client, arn)
        # 既に正しいバージョンがCURRENTの場合はスキップ
        if current_version_id == token:
            logger.info("Secret is already current, skipping version update")
            return
        service_client.update_secret_version_stage( ### terraformでLambda関数と関連付けたSecretsManagerのシークレットのバージョンのステージングラベルを更新
            SecretId=arn, #### シークレットのARNを格納
            VersionStage='AWSCURRENT', #### シークレットのバージョンのステージングラベル（AWSPENDING or AWSCURRENT）を格納
            MoveToVersionId=token, #### シークレットのバージョンIDを格納
            RemoveFromVersionId=current_version_id #### get_current_version関数を実行し、戻り値を格納
        )
        logger.info("Secret rotation completed successfully") ### ログ出力（Secret rotation completed successfully）
    except Exception as e: ### エラーハンドリング（エラー時の処理を記述）
        logger.error(f"Error in finish_secret: {str(e)}") #### ログ出力（Error in finish_secret: とエラー内容を出力）
        raise #### エラーを挙げる

# シークレット取得関数の定義
def get_secret(service_client, arn, token=None, version_stage="AWSCURRENT"): ## 関数と引数（service_client, arn, token, version_stage）の定義
    """シークレットの値を取得 (getSecret ステップ)"""
    try: ### try-except文でエラーハンドリング（エラー時の処理を記述）
        # APIパラメータの構築
        params = {
            'SecretId': arn,
            'VersionStage': version_stage
        }
        # tokenがNoneでない場合のみVersionIdを追加
        if token is not None:
            params['VersionId'] = token
        response = service_client.get_secret_value(**params) ### terraformでLambda関数と関連付けたSecretsManagerのシークレットの値を取得しローカル変数responseに格納
        return json.loads(response['SecretString']) ### シークレットの値をJSON形式で、ローカル変数responseの中身を辞書型に変換して戻り値として返す。（例）{'username': 'foo', 'password': 'bar'}
    except ClientError as e: ### エラーハンドリング（エラー時の処理を記述）
        logger.error(f"Error retrieving secret: {e}") #### ログ出力（Error retrieving secret: とエラー内容を出力）
        raise #### エラーを挙げる

def get_current_version(service_client, arn): ### 関数と引数（service_client, arn）の定義
    """現在のバージョンIDを取得"""
    try: ### try-except文でエラーハンドリング（エラー時の処理を記述）
        response = service_client.describe_secret(SecretId=arn) #### terraformでLambda関数と関連付けたSecretsManagerのシークレットの詳細情報を取得しローカル変数responseに格納
        for version in response.get('VersionIdsToStages', {}): #### VersionIdsToStagesキーの値の中からversionを取得していくループ
            if 'AWSCURRENT' in response['VersionIdsToStages'][version]: ##### VersionIdsToStagesキーのversionの値がAWSCURRENTなら
                return version ###### versionを戻り値として返す
        return None #### ローカル変数versionの値がAWSCURRENTでないならNoneを戻り値として返す
    except Exception as e: ### エラーハンドリング（エラー時の処理を記述）
        logger.error(f"Error in get_current_version: {str(e)}") #### ログ出力（Error in get_current_version: とエラー内容を出力）
        raise #### エラーを挙げる

def create_new_secret_value(current_secret): ### 関数と引数（current_secret）の定義
    """新しい認証情報を生成する"""
    new_secret = current_secret.copy() ### ローカル変数current_secretの値をローカル変数new_secretにコピー
    
    if 'password' in new_secret: #### ローカル変数new_secretの値の中にpasswordキーが存在するなら
        characters = string.ascii_letters + string.digits + "!@#$%^&*()_+-=" #### 安全な文字セットを使用
        new_secret['password'] = ''.join(random.choice(characters) for _ in range(20)) #### ローカル変数new_secretの値の中のpasswordキーの値を20文字のランダム文字列に変更
    
    return new_secret #### ローカル変数new_secretを戻り値として返す