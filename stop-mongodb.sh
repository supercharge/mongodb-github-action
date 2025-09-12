#!/bin/sh

# Keep argument positions aligned with action.yml "args" so we can reuse them in post-args
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

# Best-effort cleanup, do not fail the job if cleanup fails
set +e

echo "::group::Cleaning up MongoDB container [$MONGODB_CONTAINER_NAME]"

if docker ps -a --format '{{.Names}}' | grep -Eq "^${MONGODB_CONTAINER_NAME}$"; then
  docker rm -f "$MONGODB_CONTAINER_NAME" >/dev/null 2>&1 || true
  echo "Removed container $MONGODB_CONTAINER_NAME"
else
  echo "Container $MONGODB_CONTAINER_NAME not found; nothing to clean."
fi

echo "::endgroup::"

exit 0
