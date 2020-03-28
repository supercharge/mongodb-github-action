#!/bin/sh

REPL_COMMAND=""

if [ -n "$MONGO_REPL_SET" ]
then
    REPL_COMMAND="--bind_ip_all --replSet $MONGO_REPL_SET"
fi

docker run --name mongodb --publish 27017:27017 --detach mongo:$1 $REPL_COMMAND

if [ -n "$MONGO_REPL_SET" ]
then
    echo "initiating $MONGO_REPL_SET."
    sleep 1
    docker exec -t mongodb mongo --eval "rs.initiate({ \"_id\": \"$MONGO_REPL_SET\", \"members\": [{ \"_id\": 0, \"host\": \"localhost\" }] })"
    echo "initiated"
fi