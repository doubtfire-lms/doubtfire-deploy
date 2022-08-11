#!/bin/sh

CURRENT_BRANCH=$(git branch --show-current)

echo "You are on branch: ${CURRENT_BRANCH}"
echo
echo "This will push the following images to docker hub"
echo " - lmsdoubtfire/doubtfire-api:${CURRENT_BRANCH}-dev"
echo " - lmsdoubtfire/doubtfire-web:${CURRENT_BRANCH}-dev"
echo

read -p "Enter to continue..."

echo "Login to docker hub"
echo

docker login

docker buildx create --name mybuilder --use

function push_image {
  NAME=$1

  echo "Setting up build for $NAME"
  echo

  cd ../${NAME}

  docker buildx build --platform linux/amd64,linux/arm64 -t "lmsdoubtfire/${NAME}:${CURRENT_BRANCH}-dev" --push .
  if [ $? -ne 0 ]; then
    echo "Ensure that everything builds";
    exit 1
  fi
}


push_image "doubtfire-api"
push_image "doubtfire-web"
# push_image "doubtfire-overseer"
