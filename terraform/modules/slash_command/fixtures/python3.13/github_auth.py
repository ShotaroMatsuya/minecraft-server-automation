import time
import boto3
import json
import logging
import os
import jwt
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def get_github_token():
    """
    Get a GitHub App Installation Token using credentials stored in AWS Secrets Manager.
    Secrets Manager must store a JSON with keys: GITHUB_APP_PRIVATE_KEY, GITHUB_APP_ID, GITHUB_APP_INSTALLATION_ID
    The environment variable SECRET_ID must be set to the secret name.
    """
    try:
        client = boto3.client(
            service_name="secretsmanager", region_name="ap-northeast-1"
        )
        SecretId = os.environ["SECRET_ID"]
        get_secret_value_response = client.get_secret_value(SecretId=SecretId)
    except ClientError as e:
        logger.error(e)
        raise e
    else:
        secret = json.loads(get_secret_value_response["SecretString"])
        GITHUB_APP_PRIVATE_KEY = secret["GITHUB_APP_PRIVATE_KEY"]
        GITHUB_APP_ID = secret["GITHUB_APP_ID"]
        GITHUB_APP_INSTALLATION_ID = secret["GITHUB_APP_INSTALLATION_ID"]
        # Create JWT
        payload = {
            "iat": int(time.time()),
            "exp": int(time.time()) + 600,
            "iss": GITHUB_APP_ID,
        }
        encoded_jwt = jwt.encode(
            payload, GITHUB_APP_PRIVATE_KEY, algorithm="RS256"
        )

        # Get Access Token
        url = (
            "https://api.github.com/app/installations/"
            + f"{GITHUB_APP_INSTALLATION_ID}/access_tokens"
        )
        headers = {
            "Authorization": f"Bearer {encoded_jwt}",
            "Accept": "application/vnd.github+json",
        }
        request_obj = Request(url, headers=headers, method="POST")
        try:
            response = urlopen(request_obj)
            response_body = response.read().decode("utf-8")
            response_json = json.loads(response_body)
            GITHUB_ACCESS_TOKEN = response_json["token"]
        except HTTPError as e:
            logger.error(e)
            raise e
        except URLError as e:
            logger.error(e)
            raise e
        else:
            return GITHUB_ACCESS_TOKEN
