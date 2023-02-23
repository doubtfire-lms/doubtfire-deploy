#!/bin/bash
my_dir="$(dirname "$0")"
source "${my_dir}/../development/version.sh"

CURRENT_BRANCH=$(git branch --show-current)

echo "This script will push new development container images to docker hub for Doubtfire"
echo
echo "Run build.sh to create these images first."
echo
echo "You are building api version: ${CURRENT_API_VERSION}"
echo "You are building web version: ${CURRENT_WEB_VERSION}"
echo
echo "This will publish docker images with the following names"
echo " - lmsdoubtfire/formatif-devcontainer:${CURRENT_DEV_VERSION}-dev"
echo

read -p "Enter to continue..."

echo "Login to docker hub"
echo

docker login

docker buildx create --name mybuilder --use

function push_image {
  NAME=$1
  VERSION=$2
  FOLDER=$3
  DOCKERFILE=$4

  echo "Setting up build for $NAME"
  echo

  cd "${FOLDER}"

  docker buildx build --platform linux/amd64,linux/arm64 -f "${DOCKERFILE}" -t "lmsdoubtfire/${NAME}:${VERSION}-dev" --push .
  if [ $? -ne 0 ]; then
    echo "Ensure that everything builds";
    exit 1
  fi
}

push_image "formatif-devcontainer" "${CURRENT_DEV_VERSION}" "../" "dev.Dockerfile"
