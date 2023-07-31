#!/bin/sh

# Map input values from the GitHub Actions workflow to shell variables
MONGODB_VERSION=$1
MONGODB_REPLICA_SET=$2
MONGODB_PORT=$3
MONGODB_DB=$4
MONGODB_USERNAME=$5
MONGODB_PASSWORD=$6

# `mongosh` is used starting from MongoDB 5.x
MONGODB_CLIENT="mongosh --quiet"


if [ -z "$MONGODB_VERSION" ]; then
  echo ""
  echo "Missing MongoDB version in the [mongodb-version] input. Received value: $MONGODB_VERSION"
  echo ""

  exit 2
fi


echo "::group::Selecting correct MongoDB client"
if [ "`echo $MONGODB_VERSION | cut -c 1`" = "4" ]; then
  MONGODB_CLIENT="mongo"
fi
echo "  - Using [$MONGODB_CLIENT]"
echo ""
echo "::endgroup::"


# Helper function to wait for MongoDB to be started before moving on
wait_for_mongodb () {
  echo "::group::Waiting for MongoDB to accept connections"
  sleep 1
  TIMER=0

  until docker exec --tty mongodb $MONGODB_CLIENT -u "$MONGODB_USERNAME" -p "$MONGODB_PASSWORD" --eval "db.serverStatus()"
  do
    echo "."
    sleep 1
    TIMER=$((TIMER + 1))

    if [[ $TIMER -eq 20 ]]; then
      echo "MongoDB did not initialize within 20 seconds. Exiting."
      exit 2
    fi
  done
  echo "::endgroup::"
}


if [ -z "$MONGODB_REPLICA_SET" ]; then
  echo "::group::Starting single-node instance, no replica set"
  echo "  - port [$MONGODB_PORT]"
  echo "  - version [$MONGODB_VERSION]"
  echo "  - database [$MONGODB_DB]"
  echo "  - credentials [$MONGODB_USERNAME:$MONGODB_PASSWORD]"
  echo ""

  docker run --name mongodb --publish $MONGODB_PORT:27017 -e MONGO_INITDB_DATABASE=$MONGODB_DB -e MONGO_INITDB_ROOT_USERNAME=$MONGODB_USERNAME -e MONGO_INITDB_ROOT_PASSWORD=$MONGODB_PASSWORD --detach mongo:$MONGODB_VERSION

  if [ $? -ne 0 ]; then
      echo "Error starting MongoDB Docker container"
      exit 2
  fi
  echo "::endgroup::"

  wait_for_mongodb

  return
fi


echo "::group::Starting MongoDB as single-node replica set"
echo "  - port [$MONGODB_PORT]"
echo "  - version [$MONGODB_VERSION]"
echo "  - replica set [$MONGODB_REPLICA_SET]"
echo ""

docker run --name mongodb --publish $MONGODB_PORT:$MONGODB_PORT --detach mongo:$MONGODB_VERSION --replSet $MONGODB_REPLICA_SET --port $MONGODB_PORT

if [ $? -ne 0 ]; then
    echo "Error starting MongoDB Docker container"
    exit 2
fi
echo "::endgroup::"

wait_for_mongodb

echo "::group::Initiating replica set [$MONGODB_REPLICA_SET]"

docker exec --tty mongodb $MONGODB_CLIENT --port $MONGODB_PORT --eval "
  rs.initiate({
    \"_id\": \"$MONGODB_REPLICA_SET\",
    \"members\": [ {
       \"_id\": 0,
      \"host\": \"localhost:$MONGODB_PORT\"
    } ]
  })
"

echo "Success! Initiated replica set [$MONGODB_REPLICA_SET]"
echo "::endgroup::"


echo "::group::Checking replica set status [$MONGODB_REPLICA_SET]"
docker exec --tty mongodb $MONGODB_CLIENT --port $MONGODB_PORT --eval "
  rs.status()
"
echo "::endgroup::"
