#!/bin/sh
my_dir="$(dirname "$0")"
source "${my_dir}/version.sh"

CURRENT_BRANCH=$(git branch --show-current)

echo "This script will push new development container images to docker hub for Doubtfire"
echo
echo "Run build.sh to create these images first."
echo
echo "You are building api version: ${CURRENT_API_VERSION}"
echo "You are building web version: ${CURRENT_WEB_VERSION}"
echo
echo "This will publish docker images with the following names"
echo " - lmsdoubtfire/doubtfire-api:${CURRENT_API_VERSION}-dev"
echo " - lmsdoubtfire/doubtfire-web:${CURRENT_WEB_VERSION}-dev"
# echo " - lmsdoubtfire/doubtfire-overseer:${CURRENT_BRANCH}-dev"
echo

read -p "Enter to continue..."

echo "Login to docker hub"
echo

docker login

docker buildx create --name mybuilder --use

function push_image {
  NAME=$1
  VERSION=$2

  echo "Setting up build for $NAME"
  echo

  cd ../${NAME}

  docker buildx build --platform linux/amd64,linux/arm64 -t "lmsdoubtfire/${NAME}:${VERSION}-dev" --push .
  if [ $? -ne 0 ]; then
    echo "Ensure that everything builds";
    exit 1
  fi
}


push_image "doubtfire-api" "${CURRENT_API_VERSION}"
push_image "doubtfire-web" "${CURRENT_WEB_VERSION}"
# push_image "doubtfire-overseer"
