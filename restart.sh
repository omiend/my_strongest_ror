#!/bin/bash

# 時々プロセスが残ってしまうことがあるので念のため削除
rm ./tmp/pids/server.pid

#################################
### 実行方法
### $ ./start.sh
#################################

cd ./docker

docker-compose stop

docker-compose up
