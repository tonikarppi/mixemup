#!/usr/bin/env bash

set -e

docker pull $IMG:builder || true

docker build --target builder --cache-from $IMG:builder -t $IMG:builder .
docker build -t $IMG:latest .
