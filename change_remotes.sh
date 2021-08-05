#!/bin/sh

APP_PATH=`echo $0 | awk '{split($0,patharr,"/"); idx=1; while(patharr[idx+1] != "") { if (patharr[idx] != "/") {printf("%s/", patharr[idx]); idx++ }} }'`
APP_PATH=`cd "$APP_PATH"; pwd`

cd "${APP_PATH}"

echo "This script will automate the process of switching remote for the Doubtfire deploy project and submodules"
echo "At the end of this process you will have a origin referring to your fork, and upstream referring to the"
echo "doubtfire-lms organisation root for the project."
echo

read -p "What is your github username: " GH_USER

echo

function setup_remote {
  PROJECT=$1
  PROJECT_PATH=$2

  cd "$PROJECT_PATH"

  ORIGIN_URL="https://github.com/${GH_USER}/${PROJECT}.git"
  UPSTREAM_URL="https://github.com/doubtfire-lms/${PROJECT}.git"

  echo "Setting up $PROJECT"
  echo " - origin is now $ORIGIN_URL"
  echo " - upstream is now $UPSTREAM_URL"
  echo

  git remote set-url origin "$ORIGIN_URL"
  git remote set-url upstream "$UPSTREAM_URL" 2>>/dev/null
  if [ $? -ne 0 ]; then
    git remote add upstream "$UPSTREAM_URL"
  fi
}

setup_remote 'doubtfire-deploy' "${APP_PATH}"
setup_remote 'doubtfire-api' "${APP_PATH}/doubtfire-api"
setup_remote 'doubtfire-web' "${APP_PATH}/doubtfire-web"
setup_remote 'doubtfire-overseer' "${APP_PATH}/doubtfire-overseer"
