#!/bin/sh

# Map input values from the GitHub Actions workflow to shell variables
MONGODB_IMAGE=$1
MONGODB_VERSION=$2
MONGODB_REPLICA_SET=$3
MONGODB_PORT=$4
MONGODB_DB=$5
MONGODB_USERNAME=$6
MONGODB_PASSWORD=$7
MONGODB_CONTAINER_NAME=$8
MONGODB_KEY=$9
MONGODB_AUTHSOURCE=${10}

# `mongosh` is used starting from MongoDB 5.x
MONGODB_CLIENT="mongosh --quiet"

if [ -z "$MONGODB_IMAGE" ]; then
  echo ""
  echo "Missing MongoDB image in the [mongodb-image] input. Received value: $MONGODB_IMAGE"
  echo ""

  exit 2
fi

if [ -z "$MONGODB_VERSION" ]; then
  echo ""
  echo "Missing MongoDB version in the [mongodb-version] input. Received value: $MONGODB_VERSION"
  echo ""

  exit 2
fi

echo "::group::Using MongoDB Docker image $MONGODB_IMAGE:$MONGODB_VERSION"

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
  if [ -n "$MONGODB_USERNAME" ]; then
    MONGODB_ARGS="--username $MONGODB_USERNAME --password $MONGODB_PASSWORD --authenticationDatabase $MONGODB_AUTHSOURCE"
  fi

  # until ${WAIT_FOR_MONGODB_COMMAND}
  until docker exec --tty $MONGODB_CONTAINER_NAME $MONGODB_CLIENT --port $MONGODB_PORT $MONGODB_ARGS --eval "db.serverStatus()"
  do
    echo "."
    sleep 1
    TIMER=$((TIMER + 1))

    if [ "$TIMER" -eq 20 ]; then
      echo "MongoDB did not initialize within 20 seconds. Exiting."
      exit 2
    fi
  done
  echo "::endgroup::"
}


# check if the container already exists and remove it
## TODO: put this behind an option flag
# if [ "$(docker ps -q -f name=$MONGODB_CONTAINER_NAME)" ]; then
#  echo "Removing existing container [$MONGODB_CONTAINER_NAME]"
#  docker rm -f $MONGODB_CONTAINER_NAME
# fi

# If no replica set specified, run single node
if [ -z "$MONGODB_REPLICA_SET" ]; then
  echo "::group::Starting single-node instance, no replica set"
  echo "  - port [$MONGODB_PORT]"
  echo "  - version [$MONGODB_VERSION]"
  echo "  - database [$MONGODB_DB]"
  echo "  - credentials [$MONGODB_USERNAME:$MONGODB_PASSWORD]"
  echo "  - container-name [$MONGODB_CONTAINER_NAME]"
  echo ""

  docker run --name $MONGODB_CONTAINER_NAME \
    --publish $MONGODB_PORT:$MONGODB_PORT \
    -e MONGO_INITDB_DATABASE=$MONGODB_DB \
    -e MONGO_INITDB_ROOT_USERNAME=$MONGODB_USERNAME \
    -e MONGO_INITDB_ROOT_PASSWORD=$MONGODB_PASSWORD \
    --detach $MONGODB_IMAGE:$MONGODB_VERSION --port $MONGODB_PORT

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
if [ -n "$MONGODB_KEY" ]; then
  echo "  - keyFile provided: yes"
else
  echo "  - keyFile provided: no (random)"
fi
echo ""

# For replica set mode:
# If auth (username/password) is requested, ensure mongodb-key is provided, otherwise generate random
if { [ -n "$MONGODB_USERNAME" ] || [ -n "$MONGODB_PASSWORD" ]; } && [ -z "$MONGODB_KEY" ]; then
  MONGODB_KEY=$(dd if=/dev/urandom bs=256 count=1 2>/dev/null | base64 | tr -d '\n')
fi

MONGODB_CMD_ARGS="--port \"$MONGODB_PORT\""

if [ -n "$MONGODB_REPLICA_SET" ]; then
  MONGODB_CMD_ARGS="$MONGODB_CMD_ARGS --replSet \"$MONGODB_REPLICA_SET\""
fi

if [ -n "$MONGODB_KEY" ]; then
  # NOTE: MONGO_KEY_FILE is interpolated internally
  MONGODB_CMD_ARGS="$MONGODB_CMD_ARGS --keyFile \"\$MONGO_KEY_FILE\""
fi


# Start mongod in replica set mode, with optional auth and keyFile
# MONGO_INITDB_* envs will create the root user on first startup

docker run --name $MONGODB_CONTAINER_NAME \
  --publish $MONGODB_PORT:$MONGODB_PORT \
  $VOLUME_ARGS \
  -e MONGO_INITDB_DATABASE=$MONGODB_DB \
  -e MONGO_INITDB_ROOT_USERNAME=$MONGODB_USERNAME \
  -e MONGO_INITDB_ROOT_PASSWORD=$MONGODB_PASSWORD \
  -e MONGO_KEY=$MONGODB_KEY \
  -e MONGO_KEY_FILE=/tmp/mongo-keyfile \
  --detach \
  --entrypoint bash \
  $MONGODB_IMAGE:$MONGODB_VERSION \
  -c '\
    echo "$MONGO_KEY" > "$MONGO_KEY_FILE" && chmod 400 "$MONGO_KEY_FILE" && chown mongodb:mongodb "$MONGO_KEY_FILE" && \
    exec docker-entrypoint.sh mongod '"$MONGODB_CMD_ARGS"' \
  '

if [ $? -ne 0 ]; then
    echo "Error starting MongoDB Docker container"
    exit 2
fi

echo "::endgroup::"

wait_for_mongodb

# After mongod is up, initiate the replica set
# Use auth if credentials were supplied
MONGODB_ARGS=""
if [ -n "$MONGODB_USERNAME" ]; then
  MONGODB_ARGS="--username $MONGODB_USERNAME --password $MONGODB_PASSWORD"
fi

echo "::group::Initiating replica set [$MONGODB_REPLICA_SET]"

docker exec --tty $MONGODB_CONTAINER_NAME $MONGODB_CLIENT --port $MONGODB_PORT $MONGODB_ARGS --eval "
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
docker exec --tty $MONGODB_CONTAINER_NAME $MONGODB_CLIENT --port $MONGODB_PORT $MONGODB_ARGS --eval "rs.status()"
echo "::endgroup::"
