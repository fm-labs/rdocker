#!/bin/bash
# Build script to build the RDOCKER package using Docker.
TAGNAME=rdocker-build:latest
docker build -t $TAGNAME -f ./Dockerfile-pkgbuild . && \
docker run \
  --rm \
  --name rdocker-build-local \
  -e RDOCKER_BUILD_DIR=/app/build \
  -e RDOCKER_BUILD_WD=/app \
  --volume $PWD:/app \
  --user $(id -u):$(id -g) \
  $TAGNAME

# remove the intermediate image
docker rmi $TAGNAME