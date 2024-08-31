# coding: utf-8

import os
from datetime import datetime, timedelta

import firebase_admin
from firebase_admin import credentials, messaging


def _send_by_lib():
    SERVICE_ACCOUNT_KEY_JSON_FILE_PATH = os.environ.get(
        'SERVICE_ACCOUNT_KEY_JSON_FILE_PATH')
    REGISTRATION_TOKEN = os.environ.get('REGISTRATION_TOKEN')

    project_credentials = credentials.Certificate(
        SERVICE_ACCOUNT_KEY_JSON_FILE_PATH)
    firebase_admin.initialize_app(credential=project_credentials)

    registration_tokens = [REGISTRATION_TOKEN]

    current_datetime = datetime.now()
    current_datetime_string = current_datetime.strftime('%Y-%m-%d %H:%M:%S')

    message = messaging.MulticastMessage(
        tokens=registration_tokens,
        data={
            'custom_data_key_1': 'custom_data_value_1',
        },
        notification=messaging.Notification(
            title='Test Title (via FCM with Python)',
            body=f'This user notification was sent at {current_datetime_string}',
        ),
        android=messaging.AndroidConfig(
            notification=messaging.AndroidNotification(
                sound='default',
            ),
            ttl=timedelta(seconds=180)
        ),
        apns=messaging.APNSConfig(
            # https://developer.apple.com/documentation/usernotifications/generating-a-remote-notification
            payload=messaging.APNSPayload(
                aps=messaging.Aps(sound='bingbong.aiff'),
            ),
        ),
    )

    response = messaging.send_multicast(message)

    print('{0} messages were sent successfully'.format(response.success_count))

    if response.failure_count > 0:
        responses = response.responses
        failed_tokens = []
        for idx, resp in enumerate(responses):
            if not resp.success:
                failed_tokens.append(registration_tokens[idx])

        print('List of tokens that caused failures: {0}'.format(failed_tokens))


if __name__ == '__main__':
    _send_by_lib()
