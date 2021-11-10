#!/bin/sh

CURRENT_BRANCH=$(git branch --show-current)

echo "You are on branch: ${CURRENT_BRANCH}"
echo
echo "This will produce docker images with the following names"
echo " - lmsdoubtfire/doubtfire-api:${CURRENT_BRANCH}-dev"
echo " - lmsdoubtfire/doubtfire-web:${CURRENT_BRANCH}-dev"
# echo " - lmsdoubtfire/doubtfire-overseer:${CURRENT_BRANCH}-dev"
echo

read -p "Enter to continue..."

function build_image {
  NAME=$1

  echo "Setting up build for $NAME"
  echo

  cd ../${NAME}

  docker image rm "${NAME}:${CURRENT_BRANCH}-dev"
  docker image rm "lmsdoubtfire/${NAME}:${CURRENT_BRANCH}-dev"

  docker build -t "${NAME}:${CURRENT_BRANCH}-dev" .
  if [ $? -ne 0 ]; then
    echo "Ensure that everything builds";
    exit 1
  fi

  docker tag "${NAME}:${CURRENT_BRANCH}-dev" "lmsdoubtfire/${NAME}:${CURRENT_BRANCH}-dev"
  if [ $? -ne 0 ]; then
    echo "Tag failed...";
    exit 1
  fi
}

build_image "doubtfire-api"
build_image "doubtfire-web"
# build_image "doubtfire-overseer"