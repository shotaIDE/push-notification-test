# coding: utf-8

import os
from datetime import datetime, timedelta

import firebase_admin
from firebase_admin import credentials, messaging


def send_user_notification():
    print('Sending user notification...')

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
            body=f'This user notification was sent at {
                current_datetime_string}',
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

    response = messaging.send_each_for_multicast(message)

    print(f'{response.success_count} messages were sent successfully.')

    if response.failure_count > 0:
        responses = response.responses
        for index, response in enumerate(responses):
            if not response.success:
                padded_index = str(index).rjust(2, '0')
                registration_token = registration_tokens[index]
                error_code = response.exception.code

                print(
                    f'#{padded_index} '
                    f'registration token = {registration_token}'
                )
                print(f'#{padded_index} error code: {error_code}')


if __name__ == '__main__':
    send_user_notification()
