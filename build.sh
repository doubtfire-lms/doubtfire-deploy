#!/bin/sh

# Check for standard-version
if ! command -v standard-version &> /dev/null; then
    echo "standard-version could not be found, install it via npm i -g standard-version"
    exit
fi

APP_PATH=`echo $0 | awk '{split($0,patharr,"/"); idx=1; while(patharr[idx+1] != "") { if (patharr[idx] != "/") {printf("%s/", patharr[idx]); idx++ }} }'`
APP_PATH=`cd "$APP_PATH"; pwd`

cd "${APP_PATH}"

echo "## Rebuilding containers"
echo
echo "### Step 1: Are we ready to go?"
echo

function confirm_quit {
  echo "WARNING! Something went wrong! Do you want me to proceed?"
  select answer in "Yes" "No"; do
    case $answer in
      No)
        exit -1
        ;;
      Yes)
        break
        ;;
    esac
  done
}

echo "1. Check doubtfire-deploy"

cd "${APP_PATH}"
"${APP_PATH}/tools/git-ready-to-deploy.sh"

if [ $? -ne 0 ]; then
  echo "Please ensure that the deploy directory is free of changes. Commit and push all changes to ensure deploy can be reproduced by others.";
  confirm_quit
fi

echo
echo "2. Check doubtfire-web"

cd doubtfire-web
"${APP_PATH}/tools/git-ready-to-deploy.sh"

if [ $? -ne 0 ]; then
  confirm_quit
fi

echo
echo "3. Check doubtfire-api"

cd "${APP_PATH}/doubtfire-api"
"${APP_PATH}/tools/git-ready-to-deploy.sh"

if [ $? -ne 0 ]; then
  confirm_quit
fi


echo
echo "4. Check overseer"

cd "${APP_PATH}/doubtfire-overseer"
"${APP_PATH}/tools/git-ready-to-deploy.sh"

if [ $? -ne 0 ]; then
  confirm_quit
fi

echo
echo "### Step 2: Build web application"
echo

echo "Rebuild web?"
select answer in "Yes" "No"; do
  case $answer in
    No)
      break;
      ;;
    Yes)
      cd "${APP_PATH}/doubtfire-web"
      docker image build . -t doubtfire-web:local
      docker run -v `pwd`:/doubtfire-web -v `pwd`/dist:/doubtfire-web/dist  doubtfire-web:local npm run deploy

      if [ $? -ne 0 ]; then
        echo "Failed to build doubtfire web";
        confirm_quit
      fi
      ;;
  esac
done

echo
echo "### Step 4: Create containers"
echo

cd "${APP_PATH}"
docker compose build
