#!/usr/bin/env bash

set -e

IMG=tonikarppi/mixemup

echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
PRETTY_COMMIT=$(git log -1 $TRAVIS_COMMIT --pretty=%h)
docker tag $IMG:latest $IMG:$PRETTY_COMMIT
docker push $IMG:builder
docker push $IMG:latest
docker push $IMG:$PRETTY_COMMIT
