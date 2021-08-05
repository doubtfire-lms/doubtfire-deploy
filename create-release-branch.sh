#!/bin/sh

APP_PATH=`echo $0 | awk '{split($0,patharr,"/"); idx=1; while(patharr[idx+1] != "") { if (patharr[idx] != "/") {printf("%s/", patharr[idx]); idx++ }} }'`
APP_PATH=`cd "$APP_PATH"; pwd`

cd "${APP_PATH}"
echo "Doubtfire is currently at version `git describe --abbrev=0 --tags`"

echo 
echo "What's the name of the release branch?"
echo

read -p "Name: (Format as: 5.0.x) " RELEASE_BRANCH_NAME

echo "What's the name of the remote to push to (doubtfire-lms)"
read -p "Remote: (eg origin/upstream): " REMOTE

function prepare_branch {
  PROJECT=$1
  PROJECT_PATH=$2

  cd "${PROJECT_PATH}"

  git checkout -b $RELEASE_BRANCH_NAME
  if [ $? -ne 0 ]; then
    echo "Oh no... fix up this mess please";
    exit 1
  fi

  git push -u $REMOTE $RELEASE_BRANCH_NAME
}

prepare_branch 'doubtfire-web' "${APP_PATH}/doubtfire-web"
prepare_branch 'doubtfire-api' "${APP_PATH}/doubtfire-api"
prepare_branch 'doubtfire-overseer' "${APP_PATH}/doubtfire-overseer"
prepare_branch 'doubtfire-deploy' "${APP_PATH}"
