#!/bin/sh

# Map input values from the GitHub Actions workflow to shell variables
MONGODB_VERSION=$1
MONGODB_REPLICA_SET=$2
MONGODB_PORT=$3
MONGODB_DB=$4
MONGODB_USERNAME=$5
MONGODB_PASSWORD=$6
MONGODB_CONTAINER_NAME=$7
SHOULD_DELETE_EXISTING_CONTAINER=$8

# `mongosh` is used starting from MongoDB 5.x
MONGODB_CLIENT="mongosh --quiet"


if [ -z "$MONGODB_VERSION" ]; then
  echo ""
  echo "Missing MongoDB version in the [mongodb-version] input. Received value: $MONGODB_VERSION"
  echo ""

  exit 2
fi


echo "::group::Selecting correct MongoDB client"
if [ "`echo $MONGODB_VERSION | cut -c 1`" -le "4" ]; then
  MONGODB_CLIENT="mongo"
fi
echo "  - Using MongoDB client: [$MONGODB_CLIENT]"
echo ""
echo "::endgroup::"


# Helper function to wait for MongoDB to be started before moving on
wait_for_mongodb () {
  echo "::group::Waiting for MongoDB to accept connections"
  sleep 1
  TIMER=0

  MONGODB_ARGS=""

  if [ -z "$MONGODB_REPLICA_SET" ]
  then
    if [ -z "$MONGODB_USERNAME" ]
    then
      MONGODB_ARGS=""
    else
      # no replica set, but username given: use them as args
      MONGODB_ARGS="--username $MONGODB_USERNAME --password $MONGODB_PASSWORD"
    fi
  fi

  # until ${WAIT_FOR_MONGODB_COMMAND}
  until docker exec --tty $MONGODB_CONTAINER_NAME $MONGODB_CLIENT --port $MONGODB_PORT $MONGODB_ARGS --eval "db.serverStatus()"
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


if [[ "$SHOULD_DELETE_EXISTING_CONTAINER" == "yes" ]] || [[ "$SHOULD_DELETE_EXISTING_CONTAINER" == "1" ]]; then
  echo "::group::Deleting possibly existing Docker container named [$MONGODB_CONTAINER_NAME]"
  echo "  - container-name [$MONGODB_CONTAINER_NAME]"
  echo ""

  if [ "$(docker ps --quiet --filter name=$MONGODB_CONTAINER_NAME)" ]; then
    echo "Removing existing container [$MONGODB_CONTAINER_NAME]"
    docker rm --force $MONGODB_CONTAINER_NAME
  else
    echo "No other container with name [$MONGODB_CONTAINER_NAME] exists. Nothing to delete"
  fi

  echo "::endgroup::"
fi


if [ -z "$MONGODB_REPLICA_SET" ]; then
  echo "::group::Starting single-node instance, no replica set"
  echo "  - port [$MONGODB_PORT]"
  echo "  - version [$MONGODB_VERSION]"
  echo "  - database [$MONGODB_DB]"
  echo "  - credentials [$MONGODB_USERNAME:$MONGODB_PASSWORD]"
  echo "  - container-name [$MONGODB_CONTAINER_NAME]"
  echo ""

  docker run --name $MONGODB_CONTAINER_NAME --publish $MONGODB_PORT:$MONGODB_PORT -e MONGO_INITDB_DATABASE=$MONGODB_DB -e MONGO_INITDB_ROOT_USERNAME=$MONGODB_USERNAME -e MONGO_INITDB_ROOT_PASSWORD=$MONGODB_PASSWORD --detach mongo:$MONGODB_VERSION --port $MONGODB_PORT

  if [ $? -ne 0 ]; then
      echo "Error starting MongoDB Docker container"
      exit 2
  fi
  echo "::endgroup::"

  wait_for_mongodb

  exit 0
fi


echo "::group::Starting MongoDB as single-node replica set"
echo "  - port [$MONGODB_PORT]"
echo "  - version [$MONGODB_VERSION]"
echo "  - replica set [$MONGODB_REPLICA_SET]"
echo ""


docker run --name $MONGODB_CONTAINER_NAME --publish $MONGODB_PORT:$MONGODB_PORT --detach mongo:$MONGODB_VERSION --port $MONGODB_PORT --replSet $MONGODB_REPLICA_SET

if [ $? -ne 0 ]; then
    echo "Error starting MongoDB Docker container"
    exit 2
fi
echo "::endgroup::"

wait_for_mongodb

echo "::group::Initiating replica set [$MONGODB_REPLICA_SET]"

docker exec --tty $MONGODB_CONTAINER_NAME $MONGODB_CLIENT --port $MONGODB_PORT --eval "
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
docker exec --tty $MONGODB_CONTAINER_NAME $MONGODB_CLIENT --port $MONGODB_PORT --eval "rs.status()"
echo "::endgroup::"
