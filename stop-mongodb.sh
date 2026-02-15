#!/bin/sh

# Variables are now passed via environment variables from action.yml
MONGODB_CONTAINER_NAME="${MONGODB_CONTAINER_NAME:-mongodb}"

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
