#!/bin/bash

#################################
### 実行方法
### $ ./spring.sh rake db:migrate
#################################

cd ./docker

echo $1 $2 $3 $4 $5 $6 $7 $8 $9

docker exec creators_spring $1 $2 $3 $4 $5 $6 $7 $8 $9
