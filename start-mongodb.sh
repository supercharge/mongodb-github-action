#!/bin/sh

REPL_COMMAND=""

if [ -n "$MONGO_REPL_SET" ]
then
    REPL_COMMAND="--replSet $MONGO_REPL_SET"
fi

docker run --name mongodb --publish 27017:27017 --detach mongo:$1 $REPL_COMMAND

if [ -n "$MONGO_REPL_SET" ]
then
    sleep 1
    echo "initiating $MONGO_REPL_SET."
    docker exec -t mongodb mongo --eval "rs.initiate()"
    echo "initiated"
fi