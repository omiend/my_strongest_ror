#!/bin/zsh

#################################
### 実行方法
### $ ./spring.sh rake db:migrate
#################################

echo $1 $2 $3 $4 $5 $6 $7 $8 $9

docker exec employees_app $1 $2 $3 $4 $5 $6 $7 $8 $9
