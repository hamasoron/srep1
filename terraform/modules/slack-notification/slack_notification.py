import json
import urllib3
import os
from datetime import datetime

def lambda_handler(event, context):
    """
    GuardDuty検出結果をSlackに通知するLambda関数
    """
    
    # 環境変数の取得
    webhook_url = os.environ.get('SLACK_WEBHOOK_URL', '${slack_webhook_url}')
    channel = os.environ.get('SLACK_CHANNEL', '${slack_channel}')
    username = os.environ.get('SLACK_USERNAME', '${slack_username}')
    icon_emoji = os.environ.get('SLACK_ICON_EMOJI', '${slack_icon_emoji}')
    
    try:
        # GuardDutyイベントからの詳細情報を取得
        detail = event['detail']
        
        # 基本情報の抽出
        finding_id = detail.get('id', 'N/A')
        finding_type = detail.get('type', 'N/A')
        severity = detail.get('severity', 0)
        region = detail.get('region', 'N/A')
        account_id = detail.get('accountId', 'N/A')
        created_at = detail.get('createdAt', 'N/A')
        title = detail.get('title', 'GuardDuty Finding')
        description = detail.get('description', 'No description available')
        
        # 重要度レベルの判定
        if severity >= 7.0:
            severity_level = "🔴 HIGH"
            color = "danger"
        elif severity >= 4.0:
            severity_level = "🟡 MEDIUM"
            color = "warning"
        else:
            severity_level = "🔵 LOW"
            color = "good"
        
        # リソース情報の取得
        resource = detail.get('resource', {})
        resource_type = resource.get('resourceType', 'N/A')
        
        # 時刻のフォーマット
        if created_at != 'N/A':
            try:
                created_dt = datetime.fromisoformat(created_at.replace('Z', '+00:00'))
                formatted_time = created_dt.strftime('%Y-%m-%d %H:%M:%S UTC')
            except:
                formatted_time = created_at
        else:
            formatted_time = 'N/A'
        
        # Slackメッセージの構築
        slack_message = {
            "channel": channel,
            "username": username,
            "icon_emoji": icon_emoji,
            "attachments": [
                {
                    "color": color,
                    "title": f"🚨 GuardDuty Alert: {title}",
                    "title_link": f"https://{region}.console.aws.amazon.com/guardduty/home?region={region}#/findings?macros=current&fId={finding_id}",
                    "fields": [
                        {
                            "title": "重要度",
                            "value": f"{severity_level} ({severity}/10)",
                            "short": True
                        },
                        {
                            "title": "検出タイプ",
                            "value": finding_type,
                            "short": True
                        },
                        {
                            "title": "アカウントID",
                            "value": account_id,
                            "short": True
                        },
                        {
                            "title": "リージョン",
                            "value": region,
                            "short": True
                        },
                        {
                            "title": "リソースタイプ",
                            "value": resource_type,
                            "short": True
                        },
                        {
                            "title": "検出時刻",
                            "value": formatted_time,
                            "short": True
                        },
                        {
                            "title": "説明",
                            "value": description,
                            "short": False
                        }
                    ],
                    "footer": "AWS GuardDuty",
                    "ts": int(datetime.now().timestamp())
                }
            ]
        }
        
        # SlackにWebhookを送信
        http = urllib3.PoolManager()
        response = http.request(
            'POST',
            webhook_url,
            body=json.dumps(slack_message).encode('utf-8'),
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status == 200:
            print(f"Slack通知が正常に送信されました: {finding_id}")
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Slack notification sent successfully',
                    'finding_id': finding_id
                })
            }
        else:
            print(f"Slack通知の送信に失敗しました。ステータスコード: {response.status}")
            return {
                'statusCode': response.status,
                'body': json.dumps({
                    'message': 'Failed to send Slack notification',
                    'status_code': response.status
                })
            }
            
    except Exception as e:
        print(f"エラーが発生しました: {str(e)}")
        print(f"イベント詳細: {json.dumps(event, indent=2)}")
        
        # エラー時のSlack通知
        error_message = {
            "channel": channel,
            "username": username,
            "icon_emoji": "❌",
            "text": f"🚨 GuardDuty通知処理でエラーが発生しました\n```{str(e)}```"
        }
        
        try:
            http = urllib3.PoolManager()
            http.request(
                'POST',
                webhook_url,
                body=json.dumps(error_message).encode('utf-8'),
                headers={'Content-Type': 'application/json'}
            )
        except:
            pass
        
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error processing GuardDuty finding',
                'error': str(e)
            })
        } 