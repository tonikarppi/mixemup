#!/usr/bin/env bash

set -e

IMG=tonikarppi/mixemup

docker pull $IMG:builder || true

docker build --target builder --cache-from $IMG:builder -t $IMG:builder .
docker build --cache-from $IMG:builder -t $IMG:latest .
