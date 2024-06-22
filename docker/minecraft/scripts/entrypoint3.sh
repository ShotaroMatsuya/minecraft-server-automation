#!/bin/bash

# スクリプト内のコマンドが意図しない理由で非ゼロの終了コードを返す場合、それがエラーであるかどうかに関わらずスクリプトは終了
# set -ex

S3_BUCKET=$S3_BUCKET_NAME
S3_PREFIX=$S3_PREFIX_NAME
WEBHOOK_URL="https://hooks.slack.com/services/${WEBHOOK_PATH}"

AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-default_access_key}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-default_secret_key}

# configuration.txt ファイル内のプレースホルダを置換
sed -i "s/<aws-access-key-id>/$AWS_ACCESS_KEY_ID/" /data/plugins/dynmap/configuration.txt
sed -i "s|<aws-secret-access-key>|$AWS_SECRET_ACCESS_KEY|" /data/plugins/dynmap/configuration.txt

# function executed when container is shutdown
cleanup() {
    BACKUP_DATE_TIME=$(date +"%Y%m%d%H%M%S")
    PARTITION_DATE=$(date +"%Y")-$(date +"%m")-$(date +"%d")
    echo "Container is terminating. Uploading data from EFS to S3..."
    if [ ! -d backup/${PARTITION_DATE} ]; then
        mkdir -p backup/${PARTITION_DATE}
    fi
    FILE_NAME='minecraft-'${BACKUP_DATE_TIME}'.tar.gz'
    tar -zcvf backup/${PARTITION_DATE}/${FILE_NAME} -C /data world/ world_nether/ world_the_end/
    slack_notify ":creeper:バックアップを作成しました！！\n\nバックアップファイル名: *${S3_BUCKET}/${S3_PREFIX}/${PARTITION_DATE}/${FILE_NAME}* \n\n*削除*したい場合は、以下のリンクから削除を行ってください。\n\nhttps://s3.console.aws.amazon.com/s3/object/${S3_BUCKET}?region=ap-northeast-1&prefix=${S3_PREFIX}/${PARTITION_DATE}/${FILE_NAME}"
    aws s3 cp backup/${PARTITION_DATE}/${FILE_NAME} s3://${S3_BUCKET}/${S3_PREFIX}/${PARTITION_DATE}/

    # ラッパースクリプトで先にSIGTERMをハンドリングする
    kill -TERM "$child" 2>/dev/null
}

# trap SIGTERM signal and call cleanup
trap cleanup TERM

# script実行後にベースイメージのEnrypointをバックグランド実行
/start "$@" &
child=$!

# 前景で無限ループを実行し、cleanup完了まで待機
wait "$child"
