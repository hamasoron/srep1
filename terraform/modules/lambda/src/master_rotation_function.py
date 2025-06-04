# マスターユーザー専用ローテーション関数
## 基本ライブラリ
import os ### OS操作（ファイル操作、環境変数操作等）
import sys ### システム操作（Pythonパスの操作）
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'lib')) ### libディレクトリをPythonパスに追加（外部ライブラリをimportするための作業ディレクトリを指定）
import json ### JSON操作
import logging ### ログ出力
import random ### 乱数生成
import string ### 文字列操作
## 外部ライブラリ
import boto3 ### AWS SDK（import ライブラリ名）
from botocore.exceptions import ClientError ### AWS SDKのエラーハンドリング（from ライブラリ名.モジュール名 import 関数名（def）またはクラス名（class））
import pymysql ### MySQL接続ライブラリ

# ログ出力の設定
logger = logging.getLogger()  ## logger変数にlogging.getLogger()関数の戻り値を代入。オブジェクト = ライブラリ.関数（）
logger.setLevel(logging.INFO)  ## logger変数のログレベルをINFOレベルに設定。オブジェクト.関数（引数）

def lambda_handler(event, context):
    """マスターユーザーローテーション関数のエントリポイント"""
    logger.info(f"Master rotation event received: {json.dumps(event)}") ### SecretsManagerからのイベントをJSON形式でログ出力
    
    # Step 1: ローカル変数の定義とイベント情報の取得
    arn = event['SecretId'] ## arn変数にイベントのSecretIdキーの値を代入
    token = event['ClientRequestToken'] ## token変数にイベントのClientRequestTokenキーの値を代入
    step = event['Step'] ## step変数にイベントのStepキーの値を代入
    service_client = boto3.client('secretsmanager') ## service_client変数にboto3ライブラリのsecretsmanagerクライアントを代入
    
    try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
        if step == 'createSecret':
            create_secret(service_client, arn, token) ## create_secret関数を実行
        elif step == 'setSecret':
            set_secret(service_client, arn, token) ## set_secret関数を実行
        elif step == 'testSecret':
            test_secret(service_client, arn, token) ## test_secret関数を実行
        elif step == 'finishSecret':
            finish_secret(service_client, arn, token) ## finish_secret関数を実行
        else:
            logger.error(f"Unknown step: {step}")
            raise ValueError(f"Unknown step: {step}")
            
        logger.info(f"Successfully completed master rotation step {step} for secret {arn}") ## どのシークレット（arn）のどのステップ（createSecret、setSecret、testSecret、finishSecret）が完了したかを出力
        return {"statusCode": 200, "body": f"Master rotation step {step} completed successfully"} ## lambda_handler関数にステータスコード200を返す
        
    except Exception as e:
        logger.error(f"Error during master rotation: {str(e)}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise 

def get_secret(service_client, arn, token=None, version_stage="AWSCURRENT"):
    """現在のバージョン（AWSCURRENT）のマスターユーザーのシークレットの値（認証情報）をsecretsmanagerから取得"""
    """
    リクエストパラメータの例 
        SecretId: arn:aws:secretsmanager:ap-northeast-1:123456789012:secret:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        VersionStage: AWSCURRENT
        VersionId: 1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d
    """
    """
    取得されるシークレットの値の例
    {
        "username": "master",
        "password": "xxxxxxxxxxxxxxxxxxxx"（20文字）,
    }
    """

    try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
        ## APIパラメータの構築
        params = {
            'SecretId': arn, ## arn変数の値（今回はmasterユーザーのシークレットのARN）をSecretIdキーの値として設定
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
        new_secret['password'] = ''.join(random.choice(characters) for _ in range(20)) ## 20文字のランダムな文字列を生成し、new_secret変数のpasswordキーの値として設定
    
    return new_secret ## new_secret変数の値を戻り値として返す

def create_secret(service_client, arn, token):
    """マスターユーザーの新しいシークレットを作成しsecretsmanagerに保存"""
    try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
        try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
            get_secret(service_client, arn, token, 'AWSPENDING') ## get_secret関数を実行しAWSPENDINGバージョンのシークレットを取得
            logger.info("Secret already exists for AWSPENDING, skipping creation") ## AWSPENDINGバージョンのシークレットがすでに存在する場合、ログ出力
            return ## 関数を終了
        except ClientError as e:
            if e.response['Error']['Code'] != 'ResourceNotFoundException': ## エラーのコードがResourceNotFoundExceptionでない場合、エラーを発生させる
                raise
        
        current_secret = get_secret(service_client, arn, version_stage='AWSCURRENT') ## get_secret関数を実行しAWSCURRENTバージョンのシークレットを取得
        new_secret = create_new_secret_value(current_secret) ## create_new_secret_value関数を実行し、current_secret変数を引数として渡す。new_secret変数に戻り値を代入
        
        service_client.put_secret_value( ## service_client変数のput_secret_value関数を実行し、以下の引数を渡す
            SecretId=arn,
            ClientRequestToken=token,
            SecretString=json.dumps(new_secret),
            VersionStages=['AWSPENDING']
        )
        logger.info("New master secret created successfully") ## マスターユーザーの新しいシークレットが作成されたことをログ出力
    except Exception as e:
        logger.error(f"Error in create_secret for master: {str(e)}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise

def set_secret(service_client, arn, token):
    """マスターユーザーのパスワードをRDS側でも更新"""
    try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
        logger.info("Setting master user password using RDS modify-db-cluster API") ## マスターユーザーのパスワードをRDS側でも更新することをログ出力
        
        # 現在のシークレット（古いバージョン）と新しいシークレット（新しいバージョン）を取得
        current_secret = get_secret(service_client, arn, version_stage='AWSCURRENT') ## get_secret関数を実行しAWSCURRENTバージョンのシークレットを取得
        pending_secret = get_secret(service_client, arn, token, 'AWSPENDING') ## get_secret関数を実行しAWSPENDINGバージョンのシークレットを取得
        
        # RDSクライアントを作成
        rds_client = boto3.client('rds') ## boto3ライブラリのrdsクライアントを作成し、rds_client変数に代入
        
        # 接続先のRDSクラスターの識別子を取得（SecretsManagerのシークレットなければLambdaの環境変数から取得）
        cluster_identifier = current_secret.get('cluster_identifier') or os.environ.get('DB_CLUSTER_IDENTIFIER') ## current_secret変数のcluster_identifierキーの値を取得し、cluster_identifier変数に代入。current_secret変数のcluster_identifierキーの値がNoneの場合、os.environ.get('DB_CLUSTER_IDENTIFIER')の値をcluster_identifier変数に代入
        new_password = pending_secret.get('password') ## pending_secret変数のpasswordキーの値を取得し、new_password変数に代入
        
        if not cluster_identifier:
            raise ValueError("RDSクラスター識別子が見つかりません")
        
        if not new_password:
            raise ValueError("新しいマスターパスワードが見つかりません")
        
        # RDSクラスターのマスターパスワードを更新
        logger.info(f"Updating master password for cluster: {cluster_identifier}") ## マスターユーザーのパスワードをRDS側でも更新することをログ出力
        rds_client.modify_db_cluster(
            DBClusterIdentifier=cluster_identifier,
            MasterUserPassword=new_password, ## new_password変数の値（今回は新しいパスワード）をMasterUserPasswordキーの値として設定
            ApplyImmediately=True ## ApplyImmediatelyキーの値をTrue（今すぐに適用）として設定
        )
        
        logger.info("Master password updated successfully using RDS API") ## マスターユーザーのパスワードがRDS側でも更新されたことをログ出力
    except Exception as e:
        logger.error(f"Error in set_secret for master: {str(e)}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise

def test_database_connection(host, port, username, password):
    """新しいマスターユーザーのパスワードでデータベースに接続して単体テスト（DBのテスト）"""
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
    """新しいマスターユーザーのパスワードでデータベースに接続して結合テスト（SecretsManagerとDBの連携テスト）"""
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
        
        logger.info(f"Testing connection with new master password for user {username}") ## 新しいパスワードでデータベースに接続してテストすることをログ出力
        test_database_connection(host, port, username, password)
        logger.info(f"Successfully connected with new master password for user {username}") ## 新しいパスワードでデータベースに接続できたことをログ出力
        logger.info("Master secret tested successfully") ## マスターユーザーのパスワードがテストできたことをログ出力
    except Exception as e:
        logger.error(f"Error in test_secret for master: {str(e)}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise

def get_current_version(service_client, arn):
    """現在のバージョン（AWSCURRENT）のバージョンIDをsecretsmanagerから取得"""
    try: ## エラーハンドリング（try: 正常時の処理、except: エラー時の処理）
        response = service_client.describe_secret(SecretId=arn) ## service_client変数のdescribe_secret関数を実行し、arn変数を引数として渡す。response変数に戻り値を代入
        for version in response.get('VersionIdsToStages', {}):
            if 'AWSCURRENT' in response['VersionIdsToStages'][version]:
                return version
        return None ## 上記の条件に当てはまらない場合、Noneを戻り値として返す
    except Exception as e:
        logger.error(f"Error in get_current_version: {str(e)}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise

def finish_secret(service_client, arn, token):
    """マスターユーザーローテーションプロセスの完了（AWSPENDINGバージョンをAWSCURRENTバージョンに昇格）"""
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
        current_version_id = get_current_version(service_client, arn) ## get_current_version関数を実行し、service_client変数、arn変数を引数として渡す。current_version_id変数に戻り値を代入
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
        logger.info("Master secret rotation completed successfully") ## マスターユーザーのパスワードがローテーションされたことをログ出力
    except Exception as e:
        logger.error(f"Error in finish_secret for master: {str(e)}") ## 実際に発生したエラー内容を文字列としてキャッチしてログ出力
        raise 