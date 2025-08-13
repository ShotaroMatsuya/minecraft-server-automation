import boto3
import hmac
import hashlib
from datetime import datetime
import base64
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def authentication(headers, body):
    logger.info("1 execute authentication!")
    try:
        if suspected_replay_attack(headers):
            return False

        actual_signature = headers.get("x-slack-signature")
        expected_signature = calc_expected_signature(
            headers, base64.b64decode(body).decode("utf-8")
        )
        logger.info(f"actual_signature: {actual_signature}")
        logger.info(f"expected_signature: {expected_signature}")
        return actual_signature == expected_signature
    except Exception as e:
        logger.error(f"authentication exception: {e}")
        return False


def suspected_replay_attack(headers):
    request_ts = int(headers.get("x-slack-request-timestamp", 0))
    current_ts = int(datetime.now().timestamp())

    return abs(request_ts - current_ts) > 60 * 5


def calc_expected_signature(headers, body):
    slack_secret = get_slack_signing_secret()
    message = f"v0:{headers.get('x-slack-request-timestamp')}:{body}"
    logger.info(f"slack signature message: {message}")
    expected = (
        "v0="
        + hmac.new(
            slack_secret.encode(), message.encode(), hashlib.sha256
        ).hexdigest()
    )
    logger.info(f"expected signature: {expected}")
    return expected


def get_slack_signing_secret():
    logger.info("4 get_slack_signing_secret")
    client = boto3.client("ssm")
    parameter = client.get_parameter(
        Name="slack_signing_secret", WithDecryption=True
    )
    secret = parameter["Parameter"]["Value"]

    return secret
