#!/bin/bash

WEBHOOK_URL=$1
ALB_DNS_NAME=$2

payload="{
    \"text\": \":tada::tada:アドレスが発行されました。以下のdomainにログインしてください。:tada::tada:\n\n * $ALB_DNS_NAME *\"
}"

curl -X POST -H 'Content-Type: application/json' --data "$payload" $WEBHOOK_URL