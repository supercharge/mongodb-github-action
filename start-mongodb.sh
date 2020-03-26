#!/bin/sh

MONGODB_VERSION=$1
MONGODB_REPLICA_SET=$2

if [ -z "$MONGODB_REPLICA_SET" ]
then
  # empty replica set, start single MongoDB instance
  docker run --name mongodb --publish 27017:27017 --detach mongo:$MONGODB_VERSION
  return
fi

# Start with replica set
docker run --name mongodb --publish 27017:27017 --detach mongo:$MONGODB_VERSION --replSet $MONGODB_REPLICA_SET

echo "Initiating MongoDB replica set [$MONGODB_REPLICA_SET]"
docker exec -t mongodb mongo --eval "rs.initiate()"
echo "Check! Initiated MongoDB replica set [$MONGODB_REPLICA_SET]"
