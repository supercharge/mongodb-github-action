#!/bin/sh

# Map input values from the GitHub Actions workflow to shell variables
MONGODB_VERSION=$1
MONGODB_REPLICA_SET=$2

if [ -z "$MONGODB_REPLICA_SET" ]
then
  echo "Starting single-node instance, no replica set"
  docker run --name mongodb --publish 27017:27017 --detach mongo:$MONGODB_VERSION
  return
fi


echo "Starting as single-node replica set (in replica set [$MONGODB_REPLICA_SET])"
docker run --name mongodb --publish 27017:27017 --detach mongo:$MONGODB_VERSION mongod --replSet $MONGODB_REPLICA_SET

echo "Waiting for MongoDB to accept connections"
TIMER=0
until docker exec --tty mongodb mongo --eval "db.serverStatus()"
do
  sleep 1
  echo "."
  TIMER=$((TIMER+1))

  if [[ ${TIMER} -eq 20 ]]; then
    echo "MongoDB did not initialize within 20 seconds. Exiting."
    exit 2
  fi
done

echo "Initiating replica set [$MONGODB_REPLICA_SET]"
docker exec --tty mongodb mongo --eval "
  rs.initiate(
    JSON.stringify({
      _id: $MONGODB_REPLICA_SET,
      members: [ {
        _id: 0,
        host: localhost
      } ]
    })
  )
"
echo "Check! Initiated replica set [$MONGODB_REPLICA_SET]"
