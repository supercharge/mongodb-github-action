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
docker run --name mongodb --publish 27017:27017 --detach mongo:$MONGODB_VERSION mongod --replSet $MONGODB_REPLICA_SET

# Wait until Mongo is ready to accept connections, exit if this does not happen within 30 seconds
COUNTER=0
until docker exec --tty mongodb mongo --eval "printjson(db.serverStatus())"
do
  sleep 1
  echo "."
  COUNTER=$((COUNTER+1))

  if [[ ${COUNTER} -eq 20 ]]; then
    echo "MongoDB did not initialize within 20 seconds. Exiting."
    exit 2
  fi
done

echo "Initiating MongoDB replica set [$MONGODB_REPLICA_SET]"
docker exec --tty mongodb mongo --eval "rs.initiate()"
echo "Check! Initiated MongoDB replica set [$MONGODB_REPLICA_SET]"
