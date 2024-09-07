# coding: utf-8


import os

from fcm import send_user_notification


def test_send_user_notification(capfd):
    registration_token = os.environ.get('REGISTRATION_TOKEN')

    send_user_notification()

    out, _ = capfd.readouterr()

    assert out == (
        'Sending user notification...\n'
        '0 messages were sent successfully.\n'
        f'#00 registration token = {registration_token}\n'
        '#00 error code: NOT_FOUND\n'
    )
