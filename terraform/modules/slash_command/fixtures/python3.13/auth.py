import boto3
import hmac
import hashlib
from datetime import datetime
import base64


def authentication(headers, body):
    print("1 execute authentication!")
    try:
        if suspected_replay_attack(headers):
            return False

        actual_signature = headers.get('x-slack-signature')
        expected_signature = calc_expected_signature(
            headers, base64.b64decode(body).decode("utf-8"))
        print(actual_signature)
        print(expected_signature)
        return actual_signature == expected_signature
    except Exception as e:
        print(e)
        return False


def suspected_replay_attack(headers):
    request_ts = int(headers.get('x-slack-request-timestamp', 0))
    current_ts = int(datetime.now().timestamp())

    return abs(request_ts - current_ts) > 60 * 5


def calc_expected_signature(headers, body):
    slack_secret = get_slack_signing_secret()
    message = f"v0:{headers.get('x-slack-request-timestamp')}:{body}"
    print(message)
    expected = 'v0=' + hmac.new(slack_secret.encode(), message.encode(),
                                hashlib.sha256).hexdigest()
    print(expected)
    return expected


def get_slack_signing_secret():
    print("4 get_slack_signing_secret")
    client = boto3.client('ssm')
    parameter = client.get_parameter(Name='slack_signing_secret',
                                     WithDecryption=True)
    secret = parameter['Parameter']['Value']

    return secret
