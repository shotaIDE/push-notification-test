# coding: utf-8


import os

import pytest

from apns import send_user_notification


@pytest.mark.asyncio
async def test_send_user_notification(capfd):
    device_token = os.environ.get('DEVICE_TOKEN')

    await send_user_notification()

    out, _ = capfd.readouterr()

    assert out == (
        'Sending user notification...\n'
        f'#00 device token = {device_token}\n'
        '#00 response status code: 410\n'
    )
