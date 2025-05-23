# ライブラリのインポート
## 標準ライブラリ（プリインストール）
import os ### OS操作
import json ### JSON操作
import logging ### ログ出力
import time ### 時間操作
import random ### 乱数生成
import string ### 文字列操作
## 外部ライブラリ（pip install -r requirements.txtで一括インストール）
import boto3 ### AWS SDK
from botocore.exceptions import ClientError ### AWS SDKのエラーハンドリング

# ログ出力の設定
logger = logging.getLogger() ## ログを取得するローカル変数の定義
logger.setLevel(logging.INFO) ## ログレベル（INFO）の設定

# 関数の定義
# エントリポイント（プログラムの開始点）の関数の定義
def lambda_handler(event, context): ## 関数と引数（event, context）の定義 
    """ローテーション関数のエントリポイント"""
    logger.info(f"Rotation event received: {json.dumps(event)}") ## ログ出力（Rotation event received: とeventの内容をJSON形式で出力）
    
    ## Step 1: ローカル変数の定義とイベント情報の取得
    arn = event['SecretId'] ### event内のSecretIdキーの値を格納
    token = event['ClientRequestToken'] ### event内のClientRequestTokenキーの値を格納
    step = event['Step'] ### event内のStepキーの値を格納
    service_client = boto3.client('secretsmanager') ### SecretsManager用のboto3クライアントを格納
    
    ## Step 2: SecretsManagerのローテーションの一連の処理をstep変数の中身に応じて実行
    try: ### try-except文でエラーハンドリング（エラー時の処理を記述）
        if step == 'createSecret': #### ステップがcreateSecretなら
            create_secret(service_client, arn, token) ##### create_secret関数を実行
        elif step == 'setSecret': #### ステップがsetSecretなら
            set_secret(service_client, arn, token) ##### set_secret関数を実行
        elif step == 'testSecret': #### ステップがtestSecretなら
            test_secret(service_client, arn, token) ##### test_secret関数を実行
        elif step == 'finishSecret': #### ステップがfinishSecretなら
            finish_secret(service_client, arn, token) ##### finish_secret関数を実行
        else: #### ステップが上記のいずれでもないなら
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
    """
    https://docs.aws.amazon.com/ja_jp/secretsmanager/latest/userguide/rotate-secrets_lambda.html
    上記ページより「ローテーションステップは、createSecret、setSecret、testSecret、finishSecret」に分けることが推奨されている。
    """
    """新しいシークレットを作成 (createSecret ステップ)"""
    try: ### try-except文でエラーハンドリング（エラー時の処理を記述）
        current_secret = get_secret(service_client, arn, None, 'AWSCURRENT') ### get_secret関数を実行し、戻り値をローカル変数current_secretに格納

        new_secret = create_new_secret_value(current_secret) ### create_new_secret_value関数を実行し、戻り値をローカル変数new_secretに格納
        
        service_client.put_secret_value( ### terraformでLambda関数と関連付けたSecretsManagerのシークレットの値を更新しローカル変数responseに格納
            SecretId=arn, ### シークレットのARNを格納
            ClientRequestToken=token, ### シークレットのバージョンIDを格納
            SecretString=json.dumps(new_secret), ### シークレットの値をJSON形式で格納
            VersionStages=['AWSPENDING'] ### シークレットのバージョンのステージングラベル（AWSPENDING or AWSCURRENT）を格納
        )
    except Exception as e: ### エラーハンドリング（エラー時の処理を記述）
        logger.error(f"Error in create_secret: {str(e)}") #### ログ出力（Error in create_secret: とエラー内容を出力）
        raise #### エラーを挙げる
def set_secret(service_client, arn, token): ### 関数と引数（service_client, arn, token）の定義
    """新しいシークレット値をターゲットサービスに設定 (setSecret ステップ)"""
    try: ### try-except文でエラーハンドリング（エラー時の処理を記述）
        pending_secret = get_secret(service_client, arn, token, 'AWSPENDING') ### get_secret関数を実行し、戻り値をローカル変数pending_secretに格納
        
        logger.info("Secret updated in target system") #### ログ出力（Secret updated in target system）
    except Exception as e: ### エラーハンドリング（エラー時の処理を記述）
        logger.error(f"Error in set_secret: {str(e)}") #### ログ出力（Error in set_secret: とエラー内容を出力）
        raise #### エラーを挙げる
def test_secret(service_client, arn, token): ### 関数と引数（service_client, arn, token）の定義
    """新しいシークレットのテスト (testSecret ステップ):このステップは最悪の場合不必要なステップ"""
    try: ### try-except文でエラーハンドリング（エラー時の処理を記述）
        pending_secret = get_secret(service_client, arn, token, 'AWSPENDING') ### get_secret関数を実行し、戻り値をローカル変数pending_secretに格納
        
        logger.info("Secret tested successfully") #### ログ出力（Secret tested successfully）
    except Exception as e: ### エラーハンドリング（エラー時の処理を記述）
        logger.error(f"Error in test_secret: {str(e)}") #### ログ出力（Error in test_secret: とエラー内容を出力）
        raise
def finish_secret(service_client, arn, token): ### 関数と引数（service_client, arn, token）の定義
    """ローテーションプロセスの完了 (finishSecret ステップ)"""
    try: ### try-except文でエラーハンドリング（エラー時の処理を記述）
        service_client.update_secret_version_stage( ### terraformでLambda関数と関連付けたSecretsManagerのシークレットのバージョンのステージングラベルを更新
            SecretId=arn, #### シークレットのARNを格納
            VersionStage='AWSCURRENT', #### シークレットのバージョンのステージングラベル（AWSPENDING or AWSCURRENT）を格納
            MoveToVersionId=token, #### シークレットのバージョンIDを格納
            RemoveFromVersionId=get_current_version(service_client, arn) #### get_current_version関数を実行し、戻り値を格納
        )
        logger.info("Secret rotation completed successfully") ### ログ出力（Secret rotation completed successfully）
    except Exception as e: ### エラーハンドリング（エラー時の処理を記述）
        logger.error(f"Error in finish_secret: {str(e)}") #### ログ出力（Error in finish_secret: とエラー内容を出力）
        raise #### エラーを挙げる

# シークレット取得関数の定義
def get_secret(service_client, arn, token=None, version_stage="AWSCURRENT"): ## 関数と引数（service_client, arn, token, version_stage）の定義
    """シークレットの値を取得 (getSecret ステップ)"""
    try: ### try-except文でエラーハンドリング（エラー時の処理を記述）
        kwargs = {
            'SecretId': arn,
            'VersionStage': version_stage
        }
        if token is not None:
            kwargs['VersionId'] = token
            
        response = service_client.get_secret_value(**kwargs)
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

# 補助関数の定義
def create_new_secret_value(current_secret): ### 関数と引数（current_secret）の定義
    """新しい認証情報を生成する"""
    new_secret = current_secret.copy() ### ローカル変数current_secretの値をローカル変数new_secretにコピー
    
    if 'password' in new_secret: #### ローカル変数new_secretの値の中にpasswordキーが存在するなら
        characters = string.ascii_letters + string.digits + string.punctuation #### ローカル変数charactersに文字列の英大文字、英小文字、数字、句読点を格納
        new_secret['password'] = ''.join(random.choice(characters) for _ in range(20)) #### ローカル変数new_secretの値の中のpasswordキーの値を20文字のランダム文字列に変更
    
    return new_secret #### ローカル変数new_secretを戻り値として返す