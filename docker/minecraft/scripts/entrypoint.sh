#!/bin/bash

set -ex

export S3_BUCKET=$S3_BUCKET_NAME # minecraft-backend
S3_PREFIX=$S3_PREFIX_NAME # backups

BACKUP_DATE_TIME=$(date +"%Y%m%d%H%M%S")
PARTITION_DATE=$(date +"%Y")-$(date +"%m")-$(date +"%d")

# function executed when container is shutdown
cleanup() {
    echo "Container is terminating. Uploading data from EFS to S3..."
    if [ ! -d backup/${PARTITION_DATE} ]; then
        mkdir -p backup/${PARTITION_DATE}
    fi
    aws s3 rm s3://${S3_BUCKET}/${S3_PREFIX}/${PARTITION_DATE} --recursive
    FILE_NAME='minecraft-'${BACKUP_DATE_TIME}'.tar.gz'
    tar -zcvf backup/${PARTITION_DATE}/${FILE_NAME} -C /data/ world/
    aws s3 cp backup/${PARTITION_DATE}/${FILE_NAME} s3://${S3_BUCKET}/${S3_PREFIX}/${PARTITION_DATE}/

    kill -TERM "$child" 2>/dev/null
}

# function executed when container is started
start() {
    echo "Container is starting. Downloading data from S3..."
    LATEST_BACKUP=$(aws s3 ls --recursive s3://${S3_BUCKET}/${S3_PREFIX}/ | sort | tail -n 1 | awk '{print $4}' )
    # donwload s3 and unzip it to /data/world/
    aws s3 cp s3://${S3_BUCKET}/${LATEST_BACKUP} /data/world/
    find /data/world/ -name "*.tar.gz" -exec tar -xvf {} \;
    rm -rf /data/world/*.tar.gz
}

# trap SIGTERM signal and call cleanup
trap cleanup TERM

# execute default command in container definition
/start "$@" &
child=$!

wait "$child"
