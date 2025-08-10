import base64
import json
import zlib
import os
from urllib import request
import boto3

print("Loading function")


def lambda_handler(event, context):
    data = zlib.decompress(
        base64.b64decode(event["awslogs"]["data"]), 16 + zlib.MAX_WBITS
    )
    data_dict = json.loads(data)
    log_entire_json = json.loads(
        json.dumps(
            data_dict["logEvents"],
            ensure_ascii=False))
    log_entire_len = len(log_entire_json)
    region = context.invoked_function_arn.split(":")[3]
    log_group_name = context.log_group_name
    log_stream_name = context.log_stream_name
    log_url = (
        "https://"
        + region
        + ".console.aws.amazon.com/cloudwatch/home?region="
        + region
        + "#logEvent:group="
        + log_group_name
        + ";stream="
        + log_stream_name
    )
    post_sns_topic(log_entire_len, data_dict, log_url)
    post_to_slack(log_entire_len, data_dict, log_url)


def post_sns_topic(log_entire_len: int, data_dict: dict, log_url: str):
    for i in range(log_entire_len):
        log_dict = json.loads(
            json.dumps(data_dict["logEvents"][i], ensure_ascii=False))
        try:
            message_str = log_dict["message"]
            message_dict = json.loads(message_str)
            message_dict["log_url"] = log_url
            message = json.dumps(message_dict)
            sns = boto3.client("sns")

            # SNS Publish
            sns.publish(
                TopicArn=os.environ["SNS_TOPIC_ARN"],
                Message=message,
                Subject=os.environ["ALARM_SUBJECT"],
            )
        except Exception as e:
            print("[sns_notice_exception: ]" + str(e))


def post_to_slack(log_entire_len: int, data_dict: dict, log_url: str):
    for i in range(log_entire_len):
        log_dict = json.loads(
            json.dumps(data_dict["logEvents"][i], ensure_ascii=False)
            )
        try:
            message_str = log_dict["message"]
            message_dict = json.loads(message_str)
            user_action_info = message_dict["log"]
            send_data = {
                "username": "【UserEvent Notification】",
                "icon_emoji": ":loudspeaker:",
                "text": f"```{user_action_info}```"
            }
            r = request.Request(
                url=os.environ["WEB_HOOK_URL"],
                data=json.dumps(send_data).encode("utf-8"),
            )
            with request.urlopen(r) as response:
                response_body = response.read().decode("utf-8")
                print(response_body)
        except Exception as e:
            print("[slack_notice_exection: ]" + str(e))