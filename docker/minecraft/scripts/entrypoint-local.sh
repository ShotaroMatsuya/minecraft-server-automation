#!/bin/bash

# スクリプト内のコマンドが意図しない理由で非ゼロの終了コードを返す場合、それがエラーであるかどうかに関わらずスクリプトは終了
set -ex

AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-default_access_key}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-default_secret_key}

# configuration.txt ファイル内のプレースホルダを置換
sed -i "s|<aws-access-key-id>|$AWS_ACCESS_KEY_ID|" /data/plugins/dynmap/configuration.txt
sed -i "s|<aws-secret-access-key>|$AWS_SECRET_ACCESS_KEY|" /data/plugins/dynmap/configuration.txt

# function executed when container is shutdown
cleanup() {
    kill -TERM "$child" 2>/dev/null
}

# trap SIGTERM signal and call cleanup
trap cleanup TERM

# script実行後にベースイメージのEnrypointをバックグランド実行
/start "$@" &
child=$!

# 前景で無限ループを実行し、cleanup完了まで待機
wait "$child"
