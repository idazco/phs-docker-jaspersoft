#!/bin/sh
#
# Script to build images
#

# break on error
set -e

REPO="sylnsr"
DATE=`date +%Y.%m.%d`

image="${REPO}/jasper-server"
version="6.1.1"
echo "## ${image}"
        
## warm up cache for CI
docker pull ${image} || true

## build
docker build --pull=true -t ${image}:${DATE} .
docker build -t ${image}:${version} .
docker build -t ${image}:latest .

## for logging in CI
docker inspect ${image}:${DATE}

# push
docker push ${image}:${DATE}
docker push ${image}:${version}
docker push ${image}:latest
