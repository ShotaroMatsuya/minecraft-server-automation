import json
import os
import requests
from urllib.parse import unquote_plus

# import auth
import base64
from datetime import datetime
import boto3


def lambda_handler(event, context):
    # Slack からのリクエストを解析
    command_text = unquote_plus(
        ((base64.b64decode(event["body"]).decode("utf-8"))
            .split("text=")[1])
        .split("&")[0]
    )
    print(command_text)
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
        return response(
            """`/mc`のあとにスペースを開けてコマンドを指定してください。
            現在使用できるのは `backup`, `restore`, `list`, `help`です。
            """
        )
    commands = command_text.split()

    if commands[0] not in ["backup", "restore", "list", "help"]:
        return response("現在そのコマンドは存在しません。")

    if commands[0] == "help":
        return response(
            """`/mc `のあとにコマンドを指定してください。\n\n
            *コマンド一覧* \n\n
            - `backup`: バックアップを実行します。\n\n
            - `restore`: timestampを指定して特定のbackupからrestoreします。\n\n
            - `list`: 直近5件のbackupファイルを表示します。 \n\n
            - `help`: 実行できるコマンド一覧を表示します。"""
        )

    if commands[0] == "backup":
        headers = {
            "Authorization": f"bearer {github_token}",
            "Accept": "application/vnd.github.v3+json",
        }

        data = {"event_type": "backup"}

        api_response = requests.post(url, headers=headers, json=data)
        print(api_response.status_code)
        if api_response.status_code != 204:
            return response("Failed to dispatch GitHub workflow.", 200)
        return response(f"`{commands[0]} `が実行されました")

    if commands[0] == "restore":
        if len(commands) > 1:
            date_str = commands[1]
            try:
                # 日付フォーマットの確認
                datetime.strptime(date_str, "%Y%m%d%H%M%S")
                headers = {
                    "Authorization": f"bearer {github_token}",
                    "Accept": "application/vnd.github.v3+json",
                }

                data = {
                    "event_type": "restore",
                    "client_payload": {"recovery_datetime": date_str},
                }

                api_response = requests.post(url, headers=headers, json=data)
                print(api_response.status_code)
                if api_response.status_code != 204:
                    return response("Failed to dispatch GitHub workflow.", 200)
                return response(f"`{commands[0]} `が実行されました")

            except ValueError:
                return response(
                    f"The second word is not a valid date: {date_str}"
                )

        else:
            return response(
                "restoreコマンドにはtimestampの指定が必要です。例：20231118225051"
            )

    if commands[0] == "list":
        s3_client = boto3.client("s3")

        bucket_name = os.environ["S3_BUCKET_NAME"]
        backup_prefix = "backups/"

        def get_last_modified(obj):
            return int(obj["LastModified"].strftime("%s"))

        objs = s3_client.list_objects_v2(Bucket=bucket_name,
                                         Prefix=backup_prefix)["Contents"]
        files = [
            obj["Key"] for obj in sorted(objs, key=get_last_modified,
                                         reverse=True)
        ][:5]

        res = ""
        for file in files:
            res += f"- {file}  \n"

        return response(f"保存されているバックアップファイル \n\n{res}")

    return response("""No action was taken. Please run `/mc help`.""")


def response(message, status_code=200):
    return {
        "statusCode": status_code,
        "body": json.dumps({"text": message, "response_type": "in_channel"}),
    }


def non_authenticate_response(message="unauthorized", status_code=401):
    return {
        "statusCode": status_code,
        "body": json.dumps({"text": message, "response_type": "in_channel"}),
    }


def some_error_happened_response(message="some error happened", 
                                 status_code=500):
    return {
        "statusCode": status_code,
        "body": json.dumps({"text": message, "response_type": "in_channel"}),
    }
