#!/bin/bash

S3_BUCKET=$S3_BUCKET_NAME
S3_PREFIX=$S3_PREFIX_NAME
WEBHOOK_URL="https://hooks.slack.com/services/${WEBHOOK_PATH}"

# slack notification
slack_notify() {
    echo "Push container information to slack channel"
    local message="$1"
    if [[ -z "$message" ]]; then
        echo "Error: Message is empty"
        exit 1
    fi
    curl -X POST -H 'Content-Type: application/json' --data "{
            \"text\":\"$1\"
        }" $WEBHOOK_URL
}

BACKUP_DATE_TIME=$(date +"%Y%m%d%H%M%S")
PARTITION_DATE=$(date +"%Y")-$(date +"%m")-$(date +"%d")
echo "Container is terminating. Uploading data to S3..."
if [ ! -d backup/${PARTITION_DATE} ]; then
    mkdir -p backup/${PARTITION_DATE}
fi
FILE_NAME='minecraft-'${BACKUP_DATE_TIME}'.tar.gz'
tar -zcvf backup/${PARTITION_DATE}/${FILE_NAME} -C /data world/ world_nether/ world_the_end/
slack_notify "<!channel>\n\n:creeper:バックアップを作成しました！！\n\nバックアップファイル名: *${S3_BUCKET}/${S3_PREFIX}/${PARTITION_DATE}/${FILE_NAME}* \n\n*削除*したい場合は、以下のリンクから削除を行ってください。\n\nhttps://s3.console.aws.amazon.com/s3/object/${S3_BUCKET}?region=ap-northeast-1&prefix=${S3_PREFIX}/${PARTITION_DATE}/${FILE_NAME}"
aws s3 cp backup/${PARTITION_DATE}/${FILE_NAME} s3://${S3_BUCKET}/${S3_PREFIX}/${PARTITION_DATE}/
