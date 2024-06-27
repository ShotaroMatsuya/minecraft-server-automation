import json
import os
import boto3.exceptions
import requests
from urllib.parse import unquote_plus
import base64
from datetime import datetime, timezone, timedelta
import boto3
from botocore.exceptions import ClientError


def lambda_handler(event, context):
    try:
        command_text = parse_command_text(event)
        print(event["body"])
        print(command_text)
        return parse_request(command_text)

    except Exception as err:
        print(err)
        return some_error_happened_response()


def parse_command_text(event):
    return unquote_plus(
        (
            (base64.b64decode(event["body"]).decode("utf-8")).split("text=")[1]
        ).split("&")[0]
    )


def parse_request(command_text):
    commands = command_text.split()

    if not commands or commands[0] == "help":
        return show_help()

    command = commands[0]

    command_functions = {
        "backup": run_backup,
        "restore": run_restore,
        "list": list_backups,
        "show": show_backup_details,
        "delete": delete_backup,
        "create": create_world,
        "start": start_server,
        "stop": stop_server,
        "restart": restart_server,
        "status": check_status,
    }

    if command not in command_functions:
        return response("現在そのコマンドは存在しません。")

    return command_functions[command](commands)


def show_help():
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
- `restart`: サーバーを再起動して最新のコンテナ定義に更新します。 \n
- `status`: サーバーの状態を確認します。 \n
- `help`: 実行できるコマンド一覧を表示します。 \n
"""
    )


def run_backup(commands):
    github_token = os.environ["GITHUB_TOKEN"]
    repo_owner = os.environ["REPO_OWNER"]
    repo_name = os.environ["REPO_NAME"]
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/dispatches"

    headers = {
        "Authorization": f"bearer {github_token}",
        "Accept": "application/vnd.github.v3+json",
    }

    data = {"event_type": "backup"}

    api_response = requests.post(url, headers=headers, json=data)
    if api_response.status_code != 204:
        return response("Failed to dispatch GitHub workflow.", 200)
    return response(f"`{commands[0]} `が実行されました")


def run_restore(commands):
    if len(commands) > 1:
        date_str = commands[1]
        try:
            datetime.strptime(date_str, "%Y%m%d%H%M%S")
            github_token = os.environ["GITHUB_TOKEN"]
            repo_owner = os.environ["REPO_OWNER"]
            repo_name = os.environ["REPO_NAME"]
            url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/dispatches"
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
            return response(f"The second word is not a valid date: {date_str}")

    else:
        return response(
            "restoreコマンドにはtimestampの指定が必要です。例：20231118225051"
        )


def list_backups(commands):
    s3_client = boto3.client("s3")
    bucket_name = os.environ["S3_BUCKET_NAME"]
    backup_prefix = "backups/"

    def get_last_modified(obj):
        return int(obj["LastModified"].strftime("%s"))

    if len(commands) > 1:
        date_str = commands[1]
        try:
            datetime.strptime(date_str, "%Y-%m-%d")
            backup_prefix = f"backups/{date_str}/"

            objs = s3_client.list_objects_v2(
                Bucket=bucket_name, Prefix=backup_prefix
            )

            if "Contents" in objs:
                files = [
                    obj["Key"]
                    for obj in sorted(
                        objs["Contents"], key=get_last_modified, reverse=True
                    )
                ]
                res = "\n".join([f"- {file}" for file in files])
                return response(f"{date_str}のバックアップファイル \n\n{res}")
            else:
                return response(
                    f"Error: {date_str}にバックアップファイルはありません。"
                )
        except ClientError as e:
            return response(f"Error: {e.response['Error']['Message']}")
        except ValueError:
            return response(
                f"YYYY-MM-DD(例：2024-06-24)のフォーマットで指定してください。: {date_str}"
            )
    else:
        try:
            objs = s3_client.list_objects_v2(
                Bucket=bucket_name, Prefix=backup_prefix
            )
            if "Contents" in objs:
                files = [
                    obj["Key"]
                    for obj in sorted(
                        objs["Contents"], key=get_last_modified, reverse=True
                    )[:5]
                ]
                res = "\n".join([f"- {file}" for file in files])
                return response(f"直近5件のバックアップファイル \n\n{res}")
            else:
                return response("Error: バックアップファイルが存在しません。")
        except ClientError as e:
            return response(f"Error: {e.response['Error']['Message']}")


def show_backup_details(commands):
    if len(commands) > 1:
        s3_client = boto3.client("s3")
        bucket_name = os.environ["S3_BUCKET_NAME"]
        object_key = commands[1]
        try:
            obj = s3_client.head_object(Bucket=bucket_name, Key=object_key)
            file_metadata = {
                "File Name": object_key,
                "Size (in MB)": round(obj["ContentLength"] / (1024 * 1024), 2),
                "Last Modified (JST)": obj["LastModified"],
            }
            res = "\n".join(
                [
                    (
                        f"{key}: `{value}`"
                        if not isinstance(value, datetime)
                        else f"{key}: `{value.astimezone(timezone(timedelta(hours=+9), 'JST')).strftime('%Y-%m-%d %H:%M:%S')}`"
                    )
                    for key, value in file_metadata.items()
                ]
            )
            return response(f"{object_key}の詳細 \n\n{res}")
        except ClientError as e:
            if e.response["Error"]["Code"] == "404":
                return response(
                    f"Error: `{object_key}` は存在しませんでした。"
                )
            else:
                return response(f"Error: {e.response['Error']['Message']}")
    else:
        return response(
            """
showコマンドにはファイル名の引数が必要です。\n
例：'backups/2024-06-24/minecraft-20240622171734.tar.gz'
"""
        )


def delete_backup(commands):
    if len(commands) > 1:
        s3_client = boto3.client("s3")
        bucket_name = os.environ["S3_BUCKET_NAME"]
        object_key = commands[1]
        try:
            s3_client.delete_object(Bucket=bucket_name, Key=object_key)
            return response(f"{object_key} を削除しました。")
        except s3_client.exceptions.NoSuchKey:
            return response(f"{object_key} は存在しません。")
    else:
        return response(
            """
deleteコマンドにはファイル名の引数が必要です。\n
例：'backups/2024-06-24/minecraft-20240622171734.tar.gz'
"""
        )


def create_world(commands):
    if len(commands) > 1:
        seed_value = commands[1]
        try:
            int(seed_value)
            github_token = os.environ["GITHUB_TOKEN"]
            repo_owner = os.environ["REPO_OWNER"]
            repo_name = os.environ["REPO_NAME"]
            url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/dispatches"
            headers = {
                "Authorization": f"bearer {github_token}",
                "Accept": "application/vnd.github.v3+json",
            }

            data = {
                "event_type": "create",
                "client_payload": {"seed_value": str(seed_value)},
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
        return response("restoreコマンドにはシード値の指定が必要です。")


def start_server(commands):
    try:
        github_token = os.environ["GITHUB_TOKEN"]
        repo_owner = os.environ["REPO_OWNER"]
        repo_name = os.environ["REPO_NAME"]
        url = (
            f"https://api.github.com/repos/{repo_owner}/{repo_name}/dispatches"
        )
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


def stop_server(commands):
    try:
        github_token = os.environ["GITHUB_TOKEN"]
        repo_owner = os.environ["REPO_OWNER"]
        repo_name = os.environ["REPO_NAME"]
        url = (
            f"https://api.github.com/repos/{repo_owner}/{repo_name}/dispatches"
        )
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


def restart_server(commands):
    cluster_name = os.environ["ECS_CLUSTER_NAME"]
    service_name = os.environ["ECS_SERVICE_NAME"]
    ecs_client = boto3.client("ecs")
    try:
        list_task_response = ecs_client.list_task_definitions(
            familyPrefix="minecraft-test",
            status="ACTIVE",
            sort="DESC",
            maxResults=1,
        )
        if not list_task_response["taskDefinitionArns"]:
            raise ValueError(
                f"No active task definition found for family {service_name}"
            )
        latest_task_definition_arn = list_task_response["taskDefinitionArns"][
            0
        ]

        ecs_client.update_service(
            cluster=cluster_name,
            service=service_name,
            taskDefinition=latest_task_definition_arn,
            forceNewDeployment=True,
        )
        return response(f"{commands[0]}が実行されました")
    except boto3.exceptions.Boto3Error as e:
        return response(f"Error: {e}")
    except Exception as e:
        return response(f"Error: {e}")


def check_status(commands):
    ecs_client = boto3.client("ecs")
    elbv2_client = boto3.client("elbv2")
    cluster_name = os.environ["ECS_CLUSTER_NAME"]
    service_name = os.environ["ECS_SERVICE_NAME"]

    try:
        # サービスの詳細を取得
        service_response = ecs_client.describe_services(
            cluster=cluster_name, services=[service_name]
        )

        if not service_response["services"]:
            raise ValueError("No service found for the specified service name")

        service = service_response["services"][0]
        task_definition_arn = service["taskDefinition"]

        # ターゲットグループARNを取得
        load_balancers = service.get("loadBalancers", [])
        if not load_balancers:
            raise ValueError(
                "No load balancers found for the specified service"
            )

        # 各ターゲットグループのヘルス情報を取得
        health_check_status_list = []
        for lb in load_balancers:
            target_group_arn = lb["targetGroupArn"]
            target_group_name = target_group_arn.split(":")[-1].split("/")[
                -1
            ]  # ARNから識別子を抽出
            target_health_response = elbv2_client.describe_target_health(
                TargetGroupArn=target_group_arn
            )

            for target in target_health_response["TargetHealthDescriptions"]:
                health_check_status_list.append(
                    f"       - Target Group Name: *{target_group_name}*\n "
                    f"        Target ID: *{target['Target']['Id']}* \n "
                    f"        Health: `{target['TargetHealth']['State']}`\n"
                )

        health_check_status = "\n".join(health_check_status_list)

        # タスク定義の詳細を取得
        task_definition_response = ecs_client.describe_task_definition(
            taskDefinition=task_definition_arn
        )

        task_definition = task_definition_response["taskDefinition"]
        task_definition_created_at = (
            task_definition_response["taskDefinition"]["registeredAt"]
            .astimezone(timezone(timedelta(hours=+9), "JST"))
            .strftime("%Y-%m-%d %H:%M:%S")
        )

        # minecraftコンテナの情報を取得
        minecraft_container = None
        for container in task_definition["containerDefinitions"]:
            if container["name"] == "minecraft":
                minecraft_container = container
                break

        if minecraft_container is None:
            raise ValueError(
                "No minecraft container found in the task definition"
            )

        # 環境変数の取得
        environment = {
            env["name"]: env["value"]
            for env in minecraft_container.get("environment", [])
        }
        version = environment.get("VERSION", "指定なし")
        seed = environment.get("SEED", "指定なし")

        if not version:
            version = "指定なし"
        if not seed:
            seed = "指定なし"

        # commandとentrypointの取得
        entrypoint = " ".join(minecraft_container.get("entryPoint", []))
        command = " ".join(minecraft_container.get("command", []))

        # サービス起動時刻の取得
        # 最新のデプロイ時刻の取得
        deployments = service.get("deployments", [])
        if deployments:
            latest_deployment = max(deployments, key=lambda d: d["createdAt"])
            latest_deploy_time = (
                latest_deployment["createdAt"]
                .astimezone(timezone(timedelta(hours=+9), "JST"))
                .strftime("%Y-%m-%d %H:%M:%S")
            )
        else:
            latest_deploy_time = "情報が見つかりませんでした"

        # テキストの作成
        output_text = (
            ":computer: *Get the status of the Minecraft server:computer:* \n\n"
            f"- minecraftバージョン： `{version}` \n"
            f"- SEED値： `{seed}` \n"
            f"- サーバー起動時の実行コマンド： *{entrypoint} {command}* \n"
            f"- サーバー起動時刻： `{latest_deploy_time}` \n"
            f"- サーバーの状態：\n"
            f"  - 起動状態： `{service['status']}` \n"
            f"  - タスクの状態： *{service['runningCount']}/{service['desiredCount']}*\n"
            f"  - タスク定義の作成日時： `{task_definition_created_at}` \n"
            f"  - タスク定義のリビジョン： *{task_definition['revision']}* \n"
            f"  - ターゲットグループのヘルスチェック状態：\n{health_check_status}"
        )
        return response(output_text)

    except boto3.exceptions.Boto3Error as e:
        return response(f"Error: {e}")
    except Exception as e:
        return response(f"Error: {e}")


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


def some_error_happened_response(
    message="some error happened", status_code=500
):
    return {
        "statusCode": status_code,
        "body": json.dumps({"text": message, "response_type": "in_channel"}),
    }
