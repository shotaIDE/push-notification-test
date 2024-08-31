# coding: utf-8

from pathlib import Path
import jwt
from time import time
import os
import httpx


def get_jwt_token():
    PRIVATE_KEY_PATH = os.environ.get('APNS_AUTH_KEY_FILE_PATH')
    APNS_KEY_ID = os.environ.get('APNS_AUTH_KEY_ID')
    TEAM_ID = os.environ.get('TEAM_ID')

    private_key = Path(PRIVATE_KEY_PATH).read_text()
    headers = {
        'alg': 'ES256',
        'kid': APNS_KEY_ID
    }
    payload = {
        'iss': TEAM_ID,
        'iat': time()
    }
    
    token = jwt.encode(payload, private_key, algorithm='ES256', headers=headers)
    return token

def send_voip_push_notification(message):
    BUNDLE_ID = os.environ.get('BUNDLE_ID')
    DEVICE_TOKEN = os.environ.get('VOIP_DEVICE_TOKEN')
    USE_SANDBOX = os.environ.get('USE_SANDBOX')
    if USE_SANDBOX == '1':
        TOKEN_URL = 'https://api.sandbox.push.apple.com/3/device/'
    else:
        TOKEN_URL = 'https://api.push.apple.com/3/device/'

    token = get_jwt_token()
    
    headers = {
        'content-type': 'application/json',
        'apns-topic': f'{BUNDLE_ID}.voip',
        'apns-push-type': 'voip',
        'authorization': f'bearer {token}'
    }
    
    payload = {
        'aps': {
            'title': 'Test Message',
            'body': 'This push notification was sent by requesting APNs directly at TIME'
        }
    }

    url = f'{TOKEN_URL}{DEVICE_TOKEN}'
    
    try:
        response = httpx.post(
            url,
            headers=headers,
            data=payload
        )
        response.raise_for_status()
    except httpx.HTTPStatusError as e:
        print(f"HTTP error occurred: {e.response.status_code} - {e.response.text}")
    except Exception as e:
        print(f"An error occurred: {str(e)}")
    
    return response

if __name__ == "__main__":
    message = "あなたの音声通話に関するメッセージ"
    response = send_voip_push_notification(message)
    print(f"Response: {response.status_code}, Payload: {response.text}")
