#!/bin/sh

docker run --name mongodb --publish 27017:27017 --detach mongo:$1
