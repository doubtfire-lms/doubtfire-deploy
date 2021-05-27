#!/bin/sh

APP_PATH=`echo $0 | awk '{split($0,patharr,"/"); idx=1; while(patharr[idx+1] != "") { if (patharr[idx] != "/") {printf("%s/", patharr[idx]); idx++ }} }'`
APP_PATH=`cd "$APP_PATH"; pwd`

cd "${APP_PATH}"

echo "## Rebuilding containers"
echo
echo "### Step 1: Are we ready to go?"
echo
echo "1. Check doubtfire-deploy"

cd "${APP_PATH}"
"${APP_PATH}/tools/git-ready-to-deploy.sh"

if [ $? -ne 0 ]; then
  exit 1
fi


echo
echo "2. Check doubtfire-web"

cd doubtfire-web
"${APP_PATH}/tools/git-ready-to-deploy.sh"

if [ $? -ne 0 ]; then
  exit 1
fi

echo
echo "3. Check doubtfire-api"

cd "${APP_PATH}/doubtfire-api"
"${APP_PATH}/tools/git-ready-to-deploy.sh"

if [ $? -ne 0 ]; then
  exit 1
fi

echo
echo "### Step 2: Build web application"
echo

cd "${APP_PATH}/doubtfire-web"
npm run deploy

if [ $? -ne 0 ]; then
  exit 1
fi

echo
echo "### Step 3: Create containers"
echo

cd "${APP_PATH}"
docker-compose build
