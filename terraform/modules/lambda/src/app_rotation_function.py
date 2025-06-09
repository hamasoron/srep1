# アプリユーザー専用ローテーション関数
## 基本ライブラリ
import os ### OS操作（環境変数操作、ファイル操作）
import sys ### システム操作（Pythonパス操作）
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'lib')) ### libディレクトリをPythonパスに追加
import json ### JSON操作（JSONデータの読み込み、書き込み）
import logging ### ログ出力
import secrets ### 暗号学的に安全な乱数生成
import string ### 文字列操作
import time ### 時間関連の処理
## 外部ライブラリ
import boto3 ### AWS SDK（import ライブラリ名）
from botocore.exceptions import ClientError ### AWS SDKのエラーハンドリング（from ライブラリ名.モジュール名 import 関数名（def）またはクラス名（class））
import pymysql ### MySQL接続ライブラリ

# ログ出力の設定
logger = logging.getLogger()  ## logger変数にlogging.getLogger()関数の戻り値を代入。オブジェクト = ライブラリ.関数（）
logger.setLevel(logging.INFO)  ## logger変数のログレベルをINFOレベルに設定。オブジェクト.関数（引数）

def lambda_handler(event, context):
    """アプリユーザーローテーション関数のエントリポイント"""
    logger.info(f"App rotation event received: {json.dumps(event)}")
    
    return handle_secrets_manager_rotation(event, context)

def handle_secrets_manager_rotation(event, context):
    """SecretsManagerローテーションイベントを処理"""
    # Step 1: ローカル変数の定義とイベント情報の取得
    arn = event['SecretId'] ## arn変数にイベントのSecretIdキーの値を代入
    token = event['ClientRequestToken'] ## token変数にイベントのClientRequestTokenキーの値を代入
    step = event['Step'] ## step変数にイベントのStepキーの値を代入
    service_client = boto3.client('secretsmanager') ## service_client変数にboto3ライブラリのsecretsmanagerクライアントを代入
    
    try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
        if step == 'createSecret':
            create_secret(service_client, arn, token) ## create_secret関数を実行し、service_client変数、arn変数、token変数を引数として渡す
        elif step == 'setSecret':
            set_secret(service_client, arn, token) ## set_secret関数を実行し、service_client変数、arn変数、token変数を引数として渡す
        elif step == 'testSecret':
            test_secret(service_client, arn, token) ## test_secret関数を実行し、service_client変数、arn変数、token変数を引数として渡す
        elif step == 'finishSecret':
            finish_secret(service_client, arn, token) ## finish_secret関数を実行し、service_client変数、arn変数、token変数を引数として渡す
        else:
            logger.error(f"Unknown step: {step}") 
            raise ValueError(f"Unknown step: {step}")
            
        logger.info(f"Successfully completed app rotation step {step} for secret {arn}") ## どのシークレット（arn）のどのステップ（createSecret、setSecret、testSecret、finishSecret）が完了したかを出力
        return {"statusCode": 200, "body": f"App rotation step {step} completed successfully"} ## lambda_handler関数にステータスコード200を返す
        
    except Exception as e:
        logger.error(f"Error during app rotation: {str(e)}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise

def get_secret(service_client, arn, token=None, version_stage="AWSCURRENT"):
    """現在のバージョン（AWSCURRENT）のアプリユーザーのシークレットの値（認証情報）をsecretsmanagerから取得"""
    """
    リクエストパラメータの例 
        SecretId: arn:aws:secretsmanager:ap-northeast-1:123456789012:secret:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        VersionStage: AWSCURRENT
        VersionId: 1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d
    """
    """
    取得されるシークレットの値の例
    {
        "username": "app",
        "password": "xxxxxxxxxxxxxxxxxxxx"（20文字）,
    }
    """
    
    try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
        ## APIパラメータの構築
        params = {
            'SecretId': arn, ## arn変数の値（今回はアプリユーザーのシークレットのARN）をSecretIdキーの値として設定
            'VersionStage': version_stage ## version_stage変数の値（今回の場合はAWSCURRENT）をVersionStageキーの値として設定
        }
        ## token変数がNoneでない場合、上のAPIパラメータにVersionIdキーとtoken変数の値を追加
        if token is not None:
            params['VersionId'] = token
        response = service_client.get_secret_value(**params) ## service_client変数のget_secret_value関数を実行し、params変数を引数として渡す。response変数に戻り値を代入
        return json.loads(response['SecretString']) ## response変数のSecretStringキーの値をJSON形式でロードして戻り値として返す
    except ClientError as e:
        logger.error(f"Error retrieving secret: {e}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise

def create_new_secret_value(current_secret):
    """新しい認証情報（パスワード）を乱数で生成する"""
    """
    生成されるパスワードの例（一部の特殊文字を除いた20文字）
    "b7@p_L$3vNa8c*1TrGq#"
    """
    new_secret = current_secret.copy() ## current_secret変数の値をnew_secret変数に代入
    
    if 'password' in new_secret: ## new_secret変数の値の中にpasswordキーが含まれている場合
        characters = string.ascii_letters + string.digits + "!#$%&*()-_=+[]{}<>:;.," ## パスワードの生成に使用できる文字列を定義（/,',",@はAuroraが非対応）
        new_secret['password'] = ''.join(secrets.choice(characters) for _ in range(20)) ## 20文字の暗号学的に安全なランダム文字列を生成し、new_secret変数のpasswordキーの値として設定
    
    return new_secret ## new_secret変数の値を戻り値として返す

def create_secret(service_client, arn, token):
    """アプリユーザーの新しいシークレットを作成しsecretsmanagerに保存"""
    try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
        try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
            get_secret(service_client, arn, token, 'AWSPENDING') ## get_secret関数を実行しAWSPENDINGバージョンのシークレットを取得
            logger.info("Secret already exists for AWSPENDING, skipping creation") ## AWSPENDINGバージョンのシークレットがすでに存在する場合、ログ出力
            return ## 関数を終了
        except ClientError as e:
            if e.response['Error']['Code'] != 'ResourceNotFoundException': ## エラーのコードがResourceNotFoundExceptionでない場合、エラーを発生させる
                raise
        
        current_secret = get_secret(service_client, arn, version_stage='AWSCURRENT') ## get_secret関数を実行しAWSCURRENTバージョンのシークレットを取得
        new_secret = create_new_secret_value(current_secret) ## create_new_secret_value関数を実行し、current_secret変数を引数として渡す。new_secret変数に戼り値を代入
        
        service_client.put_secret_value( ## service_client変数のput_secret_value関数を実行し、以下の引数を渡す
            SecretId=arn,
            ClientRequestToken=token,
            SecretString=json.dumps(new_secret),
            VersionStages=['AWSPENDING']
        )
        logger.info("New app secret created successfully") ## アプリユーザーの新しいシークレットが作成されたことをログ出力
    except Exception as e:
        logger.error(f"Error in create_secret for app: {str(e)}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise

def get_master_secret_with_fallback(service_client, master_secret_arn):
    """マスターユーザーのシークレットを取得（AWSPENDINGがあればそれを優先、なければAWSCURRENT）"""
    try:
        # まずAWSPENDINGバージョンを試す（ローテーション中の場合）
        try:
            master_secret = get_secret(service_client, master_secret_arn, version_stage='AWSPENDING')
            logger.info("Using AWSPENDING version of master secret (rotation in progress)")
            return master_secret
        except ClientError as e:
            if e.response['Error']['Code'] == 'ResourceNotFoundException':
                # AWSPENDINGがない場合はAWSCURRENTを使用
                logger.info("AWSPENDING not found, using AWSCURRENT version of master secret")
                master_secret = get_secret(service_client, master_secret_arn, version_stage='AWSCURRENT')
                return master_secret
            else:
                raise
    except Exception as e:
        logger.error(f"Error retrieving master secret: {str(e)}")
        raise

def set_secret(service_client, arn, token):
    """アプリユーザーのパスワードをRDS側でも更新（マスターユーザー権限でログインして更新）"""
    try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
        logger.info("Setting app user password using master user credentials") ## アプリユーザーのパスワードをRDS側でも更新することをログ出力
        
        # 現在のシークレット（古いバージョン）と新しいシークレット（新しいバージョン）を取得
        current_secret = get_secret(service_client, arn, version_stage='AWSCURRENT') ## get_secret関数を実行しAWSCURRENTバージョンのシークレットを取得
        pending_secret = get_secret(service_client, arn, token, 'AWSPENDING') ## get_secret関数を実行しAWSPENDINGバージョンのシークレットを取得
        
        # 接続先のRDSのhostとportの情報を取得（SecretsManagerのシークレットなければLambdaの環境変数から取得）
        host = current_secret.get('host') or pending_secret.get('host') or os.environ.get('DB_ROTATION_WRITER_HOST')
        port = int(current_secret.get('port', pending_secret.get('port', os.environ.get('DB_ROTATION_PORT', 3306))))
        
        # マスターユーザーのシークレットのARNを取得（Lambdaの環境変数から取得）
        master_secret_arn = os.environ.get('MASTER_SECRET_ARN')
        if not master_secret_arn:
            raise ValueError("MASTER_SECRET_ARN環境変数が設定されていません")
        
        # マスターユーザーのシークレットの値（認証情報）を取得（フォールバック機能付き）
        master_secret = get_master_secret_with_fallback(service_client, master_secret_arn)
        master_username = master_secret.get('username') ## master_secret変数のusernameキーの値を取得し、master_username変数に代入
        master_password = master_secret.get('password') ## master_secret変数のpasswordキーの値を取得し、master_password変数に代入
        
        # ローテーション対象のアプリユーザーの情報を取得
        app_username = current_secret.get('username') ## current_secret変数のusernameキーの値を取得し、app_username変数に代入
        new_password = pending_secret.get('password') ## pending_secret変数のpasswordキーの値を取得し、new_password変数に代入
        
        # 入力値の検証（マスターユーザーのシークレットのARNが設定されているか、マスターユーザーのシークレットの値（認証情報）が取得できているか、ローテーション対象のアプリユーザーの情報が取得できているか）
        if not all([host, master_username, master_password, app_username, new_password]):
            missing_fields = []
            if not host: missing_fields.append("host") 
            if not master_username: missing_fields.append("master_username") 
            if not master_password: missing_fields.append("master_password") 
            if not app_username: missing_fields.append("app_username") 
            if not new_password: missing_fields.append("new_password") 
            
            error_msg = f"必要な認証情報が不足しています。不足フィールド: {', '.join(missing_fields)}" ## 不足フィールド（host、master_username、master_password、app_username、new_password）をログ出力
            logger.error(error_msg) ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
            raise ValueError(error_msg)
            
        logger.info(f"Updating database password for user {app_username} using master user {master_username}")
        
        # データベースに接続してパスワードを更新（マスターユーザー権限でログインして更新）
        max_retries = 3
        retry_delay = 1  # 初期待機時間（秒）
        
        for attempt in range(max_retries):
            try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
                conn = pymysql.connect( ## pymysqlライブラリのconnect関数を実行し、以下の引数を渡す
                    host=host,
                    port=port,
                    user=master_username,
                    password=master_password,
                    connect_timeout=30,
                    read_timeout=30,
                    write_timeout=30
                )
                with conn.cursor() as cur:
                    # マスターユーザーの権限でアプリユーザーのパスワードを変更
                    alter_user_query = "ALTER USER %s@'%%' IDENTIFIED BY %s"
                    cur.execute(alter_user_query, (app_username, new_password))
                    logger.info(f"Successfully updated password for user {app_username}") ## アプリユーザーのパスワードが更新されたことをログ出力
                conn.commit()
                conn.close()
                break  # 成功した場合はループを抜ける
                
            except pymysql.MySQLError as e:
                attempt_num = attempt + 1
                if attempt_num == max_retries:
                    logger.error(f"Database error during password update after {max_retries} attempts: {str(e)}")
                    raise
                else:
                    logger.warning(f"Database error on attempt {attempt_num}/{max_retries}: {str(e)}. Retrying in {retry_delay} seconds...")
                    time.sleep(retry_delay)
                    retry_delay *= 2  # 指数バックオフ（次回は2倍の待機時間）
            
        logger.info("App user password updated successfully") ## アプリユーザーのパスワードが更新されたことをログ出力
    except Exception as e:
        logger.error(f"Error in set_secret for app: {str(e)}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise

def test_database_connection(host, port, username, password):
    """新しいパスワードでデータベースに接続して単体テスト（DBのテスト）"""
    try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
        conn = pymysql.connect( ## pymysqlライブラリのconnect関数を実行し、以下の引数を渡す
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
        return True
    except Exception as e:
        logger.error(f"Database connection test failed: {str(e)}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise

def test_secret(service_client, arn, token):
    """新しいアプリユーザーのパスワードでデータベース接続をテスト（SecretsManagerとDBの連携テスト）"""
    try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
        pending_secret = get_secret(service_client, arn, token, 'AWSPENDING') ## get_secret関数を実行しAWSPENDINGバージョンのシークレットを取得
        
        # 新しいパスワードでデータベースに接続してテスト
        host = pending_secret.get('host') or os.environ.get('DB_ROTATION_WRITER_HOST')
        port = int(pending_secret.get('port', os.environ.get('DB_ROTATION_PORT', 3306)))
        username = pending_secret.get('username')
        password = pending_secret.get('password')
        
        # 入力値の検証
        if not all([host, username, password]):
            raise ValueError("必要な認証情報が不足しています")
        
        logger.info(f"Testing connection with new app password for user {username}") ## 新しいアプリユーザーのパスワードでデータベースに接続してテストすることをログ出力
        test_database_connection(host, port, username, password)
        logger.info(f"Successfully connected with new app password for user {username}") ## 新しいアプリユーザーのパスワードでデータベースに接続できたことをログ出力
        logger.info("App secret tested successfully") ## アプリユーザーのパスワードがテストできたことをログ出力
    except Exception as e:
        logger.error(f"Error in test_secret for app: {str(e)}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise

def get_current_version(service_client, arn):
    """現在のバージョン（AWSCURRENT）のバージョンIDをsecretsmanagerから取得"""
    try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
        response = service_client.describe_secret(SecretId=arn) ## service_client変数のdescribe_secret関数を実行し、arn変数を引数として渡す。response変数に戼り値を代入
        for version in response.get('VersionIdsToStages', {}):
            if 'AWSCURRENT' in response['VersionIdsToStages'][version]:
                return version
        return None ## 上記の条件に当てはまらない場合、Noneを戻り値として返す
    except Exception as e:
        logger.error(f"Error in get_current_version: {str(e)}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise

def finish_secret(service_client, arn, token):
    """アプリユーザーローテーションプロセスの完了（AWSPENDINGバージョンをAWSCURRENTバージョンに昇格）"""
    """
    finish_secret実行前 
    AWSCURRENTバージョン（古いバージョン）のシークレット
    AWSPENDINGバージョン（新しいバージョン）のシークレット
    """
    """
    finish_secret実行後 
    AWSPREVIOUSバージョン（古いバージョン）のシークレット
    AWSCURRENTバージョン（新しいバージョン）のシークレット
    """
    try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
        # 現在のバージョンIDを取得
        current_version_id = get_current_version(service_client, arn) ## get_current_version関数を実行し、service_client変数、arn変数を引数として渡す。current_version_id変数に戼り値を代入
        # 既に正しいバージョンがCURRENTの場合はスキップ
        if current_version_id == token:
            logger.info("Secret is already current, skipping version update")
            return
        service_client.update_secret_version_stage(
            SecretId=arn,
            VersionStage='AWSCURRENT',
            MoveToVersionId=token,
            RemoveFromVersionId=current_version_id
        )
        logger.info("App secret rotation completed successfully") ## アプリユーザーのパスワードがローテーションされたことをログ出力
    except Exception as e:
        logger.error(f"Error in finish_secret for app: {str(e)}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise 