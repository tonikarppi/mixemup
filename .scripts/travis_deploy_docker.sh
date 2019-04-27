#!/usr/bin/env bash

set -e

echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
export PRETTY_COMMIT=$(git log -1 $TRAVIS_COMMIT --pretty=%h)
docker tag $IMG/latest $IMG:$PRETTY_COMMIT
docker push $IMG:builder
docker push $IMG:tester
docker push $IMG:$PRETTY_COMMIT
docker push $IMG:latest