import json
import os
import requests
import urllib.parse
# import auth
import base64


def lambda_handler(event, context):
    # Slack からのリクエストを解析
    body = event.get("body", "")
    if event.get("isBase64Encoded"):
        body = base64.b64decode(body).decode("utf-8")
    parsed_body = urllib.parse.parse_qs(body)
    command_text = parsed_body.get("text", [])[0]
    try:
        # authenticated = auth.authentication(event["headers"], event["body"])
        # if not authenticated:
        #     return non_authenticate_response()
        return parse_request(command_text)

    except Exception as err:
        print(err)
        return some_error_happened_response()


def parse_request(command_text):
    # 環境変数から GitHub 関連の情報を取得
    github_token = os.environ["GITHUB_TOKEN"]
    repo_owner = os.environ["REPO_OWNER"]
    repo_name = os.environ["REPO_NAME"]
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/dispatches"
    if not command_text:
        return response("`/mc`のあとにスペースを開けてコマンドを指定してください。現在使用できるのは `backup`と`help`です。")

    if command_text not in ["backup", "help"]:
        return response("現在そのコマンドは存在しません。")

    if command_text == "help":
        return response("`/mc `のあとにコマンドを指定してください。\n\n *コマンド一覧* \n\n- `backup`: バックアップを実行します。\n\n- `help`: 実行できるコマンド一覧を表示します。")

    if command_text == "backup":
        headers = {
            "Authorization": f"bearer {github_token}",
            "Accept": "application/vnd.github.v3+json",
        }

        data = {"event_type": command_text}

        api_response = requests.post(url, headers=headers, json=data)
        print(api_response.status_code)
        if api_response.status_code != 204:
            return response(
                "Failed to dispatch GitHub workflow.", 200
            )
        return response(f"`{command_text} `が実行されました")

    return response(
        """No action was taken. Please provide
                    a valid command such as `/mc backup` or `/mc help`."""
    )


def response(message, status_code=200):
    return {"statusCode": status_code, "body": json.dumps(
        {"text": message, "response_type": "in_channel"})}


def non_authenticate_response(message="unauthorized", status_code=401):
    return {"statusCode": status_code, "body": json.dumps(
        {'text': message, 'response_type': 'in_channel'})}


def some_error_happened_response(message="some error happened",
                                 status_code=500):
    return {"statusCode": status_code, "body": json.dumps(
        {'text': message, 'response_type': 'in_channel'})}
