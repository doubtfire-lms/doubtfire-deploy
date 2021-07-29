#!/bin/sh

# Check for standard-version
if ! command -v standard-version &> /dev/null
then
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
echo "1. Check doubtfire-deploy"

cd "${APP_PATH}"
"${APP_PATH}/tools/git-ready-to-deploy.sh"

if [ $? -ne 0 ]; then
  echo "Please ensure that the deploy directory is free of changes. Commit and push all changes to ensure deploy can be reproduced by others.";
  exit 1
fi


echo
echo "2. Check doubtfire-web"

cd doubtfire-web
"${APP_PATH}/tools/git-ready-to-deploy.sh"

if [ $? -ne 0 ]; then
  exit 1
fi

echo "Do you wish to make a new doubtfire-web release?"
echo "Even if there are no changes this will still bump the version number"
select webanswer in "Skip" "Major" "Minor" "Patch"; do
    case $webanswer in
        Skip)
          echo "Not releasing doubtfire-web"
          break;
          ;;
        Major)
          echo "Creating the doubtfire-web release and bumping the major version"
          standard-version --release-as major
          break;
          ;;
        Minor)
          echo "Creating the doubtfire-web release and bumping the minor version"
          standard-version --release-as minor
          break;
          ;;
        Patch)
          echo "Creating the doubtfire-web release and bumping the patch version"
          standard-version --release-as patch
          currentbranch=$(git branch --show-current)
          git push --follow-tags origin ${currentbranch}:releases
          break;
          ;;
    esac
done

webversion=$(git describe --abbrev=0)


echo
echo "3. Check doubtfire-api"

cd "${APP_PATH}/doubtfire-api"
"${APP_PATH}/tools/git-ready-to-deploy.sh"

if [ $? -ne 0 ]; then
  exit 1
fi

echo "Do you wish to make a new doubtfire-api release?"
select answer in "Skip" "Major" "Minor" "Patch"; do
    case $answer in
        Skip)
          echo "Not releasing doubtfire-api"
          break;
          ;;
        Major)
          version='major'
          echo "Creating the doubtfire-api release and bumping the major version"
          standard-version --release-as major
          currentbranch=$(git branch --show-current)
          git push --follow-tags origin ${currentbranch}:releases
          break;
          ;;
        Minor)
          version='major'
          echo "Creating the doubtfire-api release and bumping the minor version"
          standard-version --release-as minor
          currentbranch=$(git branch --show-current)
          git push --follow-tags origin ${currentbranch}:releases
          break;
          ;;
        Patch)
          version='patch'
          echo "Creating the doubtfire-api release and bumping the patch version"
          # standard-version --release-as patch
          currentbranch=$(git branch --show-current)
          git push --follow-tags origin ${currentbranch}:releases
          break;
          ;;
    esac
done
apiversion=$(git describe --abbrev=0)

echo
echo "### Step 2: Build web application"
echo

cd "${APP_PATH}/doubtfire-web"
npm run deploy

if [ $? -ne 0 ]; then
  echo "Failed to build doubtfire web";
  exit 1
fi

echo
echo "### Step 3: Preparing the release files"
echo

cd "${APP_PATH}/releases"
DATE_WITH_TIME=`date "+%Y-%m%d-%H%M"`
mkdir $DATE_WITH_TIME
echo "$apiversion" > "${DATE_WITH_TIME}/.apiversion"
echo "$webversion" > "${DATE_WITH_TIME}/.webversion"
cp -r ./release-template/. ./${DATE_WITH_TIME}
echo "https://github.com/doubtfire-lms/doubtfire-web/blob/${webversion}/CHANGELOG.md" > ${DATE_WITH_TIME}/WEB_CHANGELOG.md
echo "https://github.com/doubtfire-lms/doubtfire-api/blob/${apiversion}/CHANGELOG.md" > ${DATE_WITH_TIME}/API_CHANGELOG.md

echo
echo "### Step 4: Create containers"
echo

cd "${APP_PATH}"
docker-compose build
