#!/bin/sh

if [ ! -d ./data/database ] ; then
  mkdir -p ./data/database
fi

docker container run \
        --name sql-maria \
        -e MYSQL_ROOT_PASSWORD=db-root-password \
        -e MYSQL_USER=dfire \
        -e MYSQL_PASSWORD=pwd \
        -e MYSQL_DATABASE=doubtfire \
        -p 3306:3306 \
        -v `pwd`/data/database:/var/lib/mysql \
        -d mariadb

