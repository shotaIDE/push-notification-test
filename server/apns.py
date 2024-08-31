# coding: utf-8

import asyncio
from datetime import datetime
from pathlib import Path
import jwt
from time import time
import os
import httpx

# https://developer.apple.com/documentation/usernotifications/establishing-a-token-based-connection-to-apns
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

# https://developer.apple.com/documentation/usernotifications/sending-notification-requests-to-apns
async def send_user_notification():
    print('Sending user notification...')

    BUNDLE_ID = os.environ.get('BUNDLE_ID')
    DEVICE_TOKEN = os.environ.get('DEVICE_TOKEN')
    USE_SANDBOX = os.environ.get('USE_SANDBOX')
    if USE_SANDBOX == '1':
        TOKEN_URL = 'https://api.sandbox.push.apple.com/3/device/'
    else:
        TOKEN_URL = 'https://api.push.apple.com/3/device/'

    token = get_jwt_token()
    
    headers = {
        'authorization': f'bearer {token}',
        'apns-push-type': 'alert',
        'apns-topic': f'{BUNDLE_ID}'
    }

    current_datetime = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    payload = {
        'aps': {
            "alert": {
                "title": "Test Message",
                "sound": "default",
                "body": f"This push notification was sent by requesting APNs directly at {current_datetime}"
            }
        }
    }

    url = f'{TOKEN_URL}{DEVICE_TOKEN}'
    
    async with httpx.AsyncClient(http2=True) as client:
        response = await client.post(
            url,
            headers=headers,
            json=payload
        )

    return response


# https://developer.apple.com/documentation/usernotifications/sending-notification-requests-to-apns
async def send_voip_push_notification():
    print('Sending VoIP notification...')

    BUNDLE_ID = os.environ.get('BUNDLE_ID')
    DEVICE_TOKEN = os.environ.get('VOIP_DEVICE_TOKEN')
    USE_SANDBOX = os.environ.get('USE_SANDBOX')
    if USE_SANDBOX == '1':
        TOKEN_URL = 'https://api.sandbox.push.apple.com/3/device/'
    else:
        TOKEN_URL = 'https://api.push.apple.com/3/device/'

    token = get_jwt_token()
    
    headers = {
        'authorization': f'bearer {token}',
        'apns-push-type': 'voip',
        'apns-topic': f'{BUNDLE_ID}'
    }

    current_datetime = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    payload = {
        'aps': {
            "alert": {
                "title": "Test Message",
                "sound": "default",
                "body": f"This push notification was sent by requesting APNs directly at {current_datetime}"
            }
        }
    }

    url = f'{TOKEN_URL}{DEVICE_TOKEN}'
    
    async with httpx.AsyncClient(http2=True) as client:
        response = await client.post(
            url,
            headers=headers,
            json=payload
        )

    return response


if __name__ == "__main__":
    VOIP_PUSH = os.environ.get('VOIP_PUSH')

    loop = asyncio.get_event_loop()
    response = loop.run_until_complete(
        send_voip_push_notification() if VOIP_PUSH == 'true' else send_user_notification()
    )

    print(f"Status code: {response.status_code}")
    print(f"Body: {response.text}")
