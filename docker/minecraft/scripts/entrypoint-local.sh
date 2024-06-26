#!/bin/bash

# スクリプト内のコマンドが意図しない理由で非ゼロの終了コードを返す場合、それがエラーであるかどうかに関わらずスクリプトは終了
set -ex

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
