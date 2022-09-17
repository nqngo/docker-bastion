#!/bin/bash
# Manual convenient script to build the image

DOCKERHUB_USER="nqngo1"
DOCKERHUB_REPO="bastion"

# Build the tag version string
DATE=`date +%Y.%m`
MINOR_VER=00
if [[ $# -gt 0 ]]; then
  MINOR_VER=$1
fi
VERSION="$DATE-$MINOR_VER"

# Build the image
echo "Building docker image with tag $VERSION..."
docker build --tag=$DOCKERHUB_USER/$DOCKERHUB_REPO:latest \
			 --tag $DOCKERHUB_USER/$DOCKERHUB_REPO:$VERSION \
			 --build-arg VERSION=$VERSION .