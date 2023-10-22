#!/bin/bash

# set -ex

# Volumeにworldを移動する
cp -r /world /data/
chown minecraft:minecraft /data/world -R

export S3_BUCKET=$S3_BUCKET_NAME # minecraft-backend
S3_PREFIX=$S3_PREFIX_NAME # backups

BACKUP_DATE_TIME=$(date +"%Y%m%d%H%M%S")
PARTITION_DATE=$(date +"%Y")-$(date +"%m")-$(date +"%d")

WEBHOOK_URL=$WEBHOOK_URL

echo $WEBHOOK_URL

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

# function executed when container is shutdown
cleanup() {
    echo "Container is terminating. Uploading data from EFS to S3..."
    if [ ! -d backup/${PARTITION_DATE} ]; then
        mkdir -p backup/${PARTITION_DATE}
    fi
    # aws s3 rm s3://${S3_BUCKET}/${S3_PREFIX}/${PARTITION_DATE} --recursive
    FILE_NAME='minecraft-'${BACKUP_DATE_TIME}'.tar.gz'
    tar -zcvf backup/${PARTITION_DATE}/${FILE_NAME} -C /data/ world/
    slack_notify ":creeper:バックアップを作成しました！！\n\nバックアップファイル名: *${S3_BUCKET}/${S3_PREFIX}/${PARTITION_DATE}/${FILE_NAME}* \n\n*削除*したい場合は、以下のリンクから削除を行ってください。\n\nhttps://s3.console.aws.amazon.com/s3/object/${S3_BUCKET}?region=ap-northeast-1&prefix=${S3_PREFIX}/${PARTITION_DATE}/${FILE_NAME}"
    aws s3 cp backup/${PARTITION_DATE}/${FILE_NAME} s3://${S3_BUCKET}/${S3_PREFIX}/${PARTITION_DATE}/

    kill -TERM "$child" 2>/dev/null
}

# function executed when container is started
echo "Container is starting. Downloading data from S3..."
LATEST_BACKUP=$(aws s3 ls --recursive s3://${S3_BUCKET}/${S3_PREFIX}/ | sort | tail -n 1 | awk '{print $4}' )
LAST_MODIFIED=$(aws s3api head-object --bucket ${S3_BUCKET} --key ${LATEST_BACKUP} | jq -r .LastModified | xargs -I {} date -d "{}" "+%Y-%m-%d %H:%M:%S")

# donwload s3 and unzip it to /data/world/
aws s3 cp s3://${S3_BUCKET}/${LATEST_BACKUP} /data/world/
find /data/world/ -name "*.tar.gz" -exec tar -xvf {} \;
rm -rf /data/world/*.tar.gz
slack_notify ":creeper:バックアップをリストアしました！！\n\nバックアップファイルの作成日時: *${LAST_MODIFIED}*\nバックアップファイルPATH: *${S3_BUCKET}/${LATEST_BACKUP}*"


# trap SIGTERM signal and call cleanup
trap cleanup TERM

# execute default command in container definition
/start "$@" &
child=$!

wait "$child"
