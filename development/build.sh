#!/bin/sh
my_dir="$(dirname "$0")"
source "${my_dir}/version.sh"

CURRENT_BRANCH=$(git branch --show-current)

echo "This script will create new development container images for Doubtfire"
echo
echo "When there are changes to the configuration or dependencies of a container, the version should be incremented."
echo "Update this in ${my_dir}/version.sh as well as in the docker-compose.yml file in the development folder."
echo
echo "Run publish.sh when you are ready to push the new images to docker hub."
echo
echo " You are on branch:     ${CURRENT_BRANCH}"
echo "           api version: ${CURRENT_API_VERSION}"
echo "           web version: ${CURRENT_WEB_VERSION}"
echo " dev container version: ${CURRENT_WEB_VERSION}"
echo
echo "This will produce docker images with the following names"
echo " - lmsdoubtfire/doubtfire-api:${CURRENT_API_VERSION}-dev"
echo " - lmsdoubtfire/doubtfire-web:${CURRENT_WEB_VERSION}-dev"
echo " - lmsdoubtfire/formatif-devcontainer:${CURRENT_DEV_VERSION}-dev"
# echo " - lmsdoubtfire/doubtfire-overseer:${CURRENT_BRANCH}-dev"
echo

read -p "Enter to continue..."

function build_image {
  NAME=$1
  VERSION=$2
  FOLDER=$3
  DOCKERFILE=$4

  echo "Setting up build for $NAME"
  echo

  cd ${FOLDER}

  docker image rm "${NAME}:${VERSION}-dev" 2>/dev/null
  docker image rm "lmsdoubtfire/${NAME}:${VERSION}-dev" 2>/dev/null

  docker build -f "${DOCKERFILE}" -t "${NAME}:${VERSION}-dev" .
  if [ $? -ne 0 ]; then
    echo "Ensure that everything builds";
    exit 1
  fi

  docker tag "${NAME}:${VERSION}-dev" "lmsdoubtfire/${NAME}:${VERSION}-dev"
  if [ $? -ne 0 ]; then
    echo "Tag failed...";
    exit 1
  fi
}


# build_image "doubtfire-api" "${CURRENT_API_VERSION}"  "../doubtfire-api" "Dockerfile"
# build_image "doubtfire-web" "${CURRENT_WEB_VERSION}"  "../doubtfire-web" "Dockerfile"
# # build_image "doubtfire-overseer"

build_image "formatif-devcontainer" "${CURRENT_DEV_VERSION}" "../" "dev.Dockerfile"
