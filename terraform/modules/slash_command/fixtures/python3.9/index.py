import json
import os
import requests
from urllib.parse import unquote_plus

# import auth
import base64
from datetime import datetime, timezone, timedelta
import boto3
from botocore.exceptions import ClientError


def lambda_handler(event, context):
    # Slack からのリクエストを解析
    command_text = unquote_plus(
        ((base64.b64decode(event["body"]).decode("utf-8"))
            .split("text=")[1])
        .split("&")[0]
    )
    print(event["body"])
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
            `help`コマンドで実行できるコマンド一覧を表示します。
            """
        )
    commands = command_text.split()

    if commands[0] not in [
        "backup",
        "restore",
        "list",
        "show",
        "delete",
        "create",
        "start",
        "stop",
        "help"
    ]:
        return response("現在そのコマンドは存在しません。")

    if commands[0] == "help":
        return response(
            """`/mc `のあとにコマンドを指定してください。\n\n
*コマンド一覧* \n\n
- `backup`: バックアップを実行します。\n
- `restore`: timestampを指定して特定のbackupからrestoreします。\n
- `list`: 直近5件のbackupファイルを表示します。日時(例：2024-06-24)を指定することもできます。 \n
- `show`: バックアップファイルを指定するとファイルの詳細（作成日時やファイルサイズなど）を参照できます。\n
- `create`: Seed値を指定してworldを新たに生成します。 \n
- `start`: 直近のセーブデータからサーバーを起動します。 \n
- `stop`: セーブしてサーバーをシャットダウンします。 \n
- `delete`: 特定のバックアップファイルを削除します。 \n
- `help`: 実行できるコマンド一覧を表示します。 \n
""")

    if commands[0] == "backup":
        headers = {
            "Authorization": f"bearer {github_token}",
            "Accept": "application/vnd.github.v3+json",
        }

        data = {"event_type": "backup"}

        api_response = requests.post(url, headers=headers, json=data)
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

        if len(commands) > 1:
            date_str = commands[1]
            try:
                #  YYYY-MM-DDのフォーマットの確認
                datetime.strptime(date_str, "%Y-%m-%d")
                backup_prefix = f"backups/{date_str}/"

                objs = s3_client.list_objects_v2(
                    Bucket=bucket_name,
                    Prefix=backup_prefix)
                
                if 'Contents' in objs:
                    files = [
                        obj["Key"] for obj in sorted(objs["Contents"],
                                                     key=get_last_modified,
                                                     reverse=True)
                    ]
                    res = ""
                    for file in files:
                        res += f"- {file}  \n"
                    return response(f"{date_str}のバックアップファイル \n\n{res}")
                else:
                    return response(f"Error: {date_str}にバックアップファイルはありません。")
            except ClientError as e:
                return response(f"Error: {e.response['Error']['Message']}")
            except ValueError:
                return response(
                    f"YYYY-MM-DD(例：2024-06-24)のフォーマットで指定してください。: {date_str}"
                )
        else:
            try:
                # 最新の5件のファイルを表示
                objs = s3_client.list_objects_v2(
                    Bucket=bucket_name,
                    Prefix=backup_prefix)
                if 'Contents' in objs:
                    files = [
                        obj["Key"] for obj in sorted(objs["Contents"],
                                                     key=get_last_modified,
                                                     reverse=True)
                    ][:5]
                    res = ""
                    for file in files:
                        res += f"- {file}  \n"
                    return response(f"直近5件のバックアップファイル \n\n{res}")
                else:
                    return response("Error: バックアップファイルが存在しません。")
            except ClientError as e:
                return response(f"Error: {e.response['Error']['Message']}")

    if commands[0] == "show":
        s3_client = boto3.client("s3")
        bucket_name = os.environ["S3_BUCKET_NAME"]
        if len(commands) > 1:
            object_key = commands[1]
            try:
                obj = s3_client.head_object(
                    Bucket=bucket_name, Key=object_key)
                file_metadata = {
                    'File Name': object_key,
                    'Size (in MB)': round(obj['ContentLength']/(1024*1024), 2),
                    'Last Modified (JST)': obj['LastModified'],
                }
                res = ""
                for key, value in file_metadata.items():
                    if isinstance(value, datetime):
                        jst = timezone(timedelta(hours=+9), 'JST')
                        value = value.astimezone(jst).strftime(
                            "%Y-%m-%d %H:%M:%S"
                        )
                    res += f"{key}: `{value}` \n"
                return response(f"{object_key}の詳細 \n\n{res}")
            except ClientError as e:
                if e.response['Error']['Code'] == '404':
                    return response(f"Error: `{object_key}` は存在しませんでした。")
                else:
                    return response(f"Error: {e.response['Error']['Message']}")
        else:
            return response("""
showコマンドにはファイル名の引数が必要です。\n
例：'backups/2024-06-24/minecraft-20240622171734.tar.gz'
""")

    if commands[0] == 'delete':
        s3_client = boto3.client('s3')
        bucket_name = os.environ['S3_BUCKET_NAME']
        if len(commands) > 1:
            object_key = commands[1]
            try:
                s3_client.delete_object(Bucket=bucket_name, Key=object_key)
                return response(f"{object_key} を削除しました。")
            except s3_client.exceptions.NoSuchKey:
                return response(f"{object_key} は存在しません。")
        else:
            return response("""
deleteコマンドにはファイル名の引数が必要です。\n
例：'backups/2024-06-24/minecraft-20240622171734.tar.gz'
""")

    if commands[0] == 'create':
        if len(commands) > 1:
            seed_value = commands[1]
            try:
                seed_value = int(seed_value)
                headers = {
                    "Authorization": f"bearer {github_token}",
                    "Accept": "application/vnd.github.v3+json",
                }

                data = {
                    "event_type": "create",
                    "client_payload": {"seed_value": seed_value},
                }

                api_response = requests.post(url, headers=headers, json=data)
                if api_response.status_code != 204:
                    return response("Failed to dispatch GitHub workflow.", 200)
                return response(f"`{commands[0]} `が実行されました")

            except ValueError:
                return response(
                    f"The second word is not a valid value: {seed_value}"
                )

        else:
            return response(
                "restoreコマンドにはシード値の指定が必要です。"
            )
    if commands[0] == 'start':
        try:
            headers = {
                "Authorization": f"bearer {github_token}",
                "Accept": "application/vnd.github.v3+json",
            }
            data = {"event_type": "start"}

            api_response = requests.post(url, headers=headers, json=data)
            if api_response.status_code != 204:
                return response("Failed to dispatch GitHub workflow.", 200)
            return response(f"{commands[0]}が実行されました")
        except Exception as e:
            return response(f"Error: {e}")

    if commands[0] == 'stop':
        try:
            headers = {
                "Authorization": f"bearer {github_token}",
                "Accept": "application/vnd.github.v3+json",
            }
            data = {"event_type": "stop"}

            api_response = requests.post(url, headers=headers, json=data)
            if api_response.status_code != 204:
                return response("Failed to dispatch GitHub workflow.", 200)
            return response(f"{commands[0]}が実行されました")
        except Exception as e:
            return response(f"Error: {e}")
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
