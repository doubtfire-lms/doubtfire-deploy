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

echo "## Generate Release Notes and Push to Release Branch"

echo
echo "### Step 1: Build"
echo

cd "${APP_PATH}"
"${APP_PATH}/build.sh"

if [ $? -ne 0 ]; then
  echo "Ensure that everything builds";
  exit 1
fi

echo
echo "### Step 2. Update version tags"
echo 

select answer in "Full" "Prerelease"; do
  case $answer in
    Full)
      break;
      ;;
    Prerelease)
      PRERELEASE="--prerelease"
      break;
      ;;
  esac
done

select answer in "Skip" "Auto" "Major" "Minor" "Patch"; do

  function prepare_release {
    PROJECT=$1
    PROJECT_PATH=$2

    cd "${PROJECT_PATH}"

    echo "${PROJECT} is at version `git describe --abbrev=0 --tags`"
    case $answer in
      Skip)
        echo "Not changing ${PROJECT} tag"
        break;
        ;;
      Auto)
        echo "Creating ${PROJECT} release and bumping the major version"
        standard-version $PRERELEASE
        break;
        ;;
      Major)
        echo "Creating ${PROJECT} release and bumping the major version"
        standard-version --release-as major $PRERELEASE
        break;
        ;;
      Minor)
        echo "Creating ${PROJECT} release and bumping the minor version"
        standard-version --release-as minor $PRERELEASE
        break;
        ;;
      Patch)
        echo "Creating ${PROJECT} release and bumping the patch version"
        standard-version --release-as patch $PRERELEASE
        break;
        ;;
    esac

    CURRENT_BRANCH=$(git branch --show-current)
    RELEASE_VERSION=`git describe --abbrev=0 --tags`
    while [ $CURRENT_BRANCH != $RELEASE_VERSION ]; do
      echo "$PROJECT does not match release branch naming: $CURRENT_BRANCH != $RELEASE_VERSION"
      read -p "Fix then press enter to continue"

      CURRENT_BRANCH=$(git branch --show-current)
      RELEASE_VERSION=`git describe --abbrev=0 --tags`
    done
    echo
  }

  prepare_release 'doubtfire-web' "${APP_PATH}/doubtfire-web"
  WEB_VERSION=$(git describe --abbrev=0 --tags)

  prepare_release 'doubtfire-api' "${APP_PATH}/doubtfire-api"
  API_VERSION=$(git describe --abbrev=0 --tags)

  prepare_release 'doubtfire-overseer' "${APP_PATH}/doubtfire-overseer"
  OVERSEER_VERSION=$(git describe --abbrev=0 --tags)

  echo
  echo "### Step 3: Prepare deploy for release"
  echo

  cd "${APP_PATH}/releases"
  DATE_WITH_TIME=`date "+%Y-%m%d-%H%M"`
  mkdir $DATE_WITH_TIME
  echo "$API_VERSION" > "${DATE_WITH_TIME}/.apiversion"
  echo "$WEB_VERSION" > "${DATE_WITH_TIME}/.webversion"
  echo "$OVERSEER_VERSION" > "${DATE_WITH_TIME}/.overseer"
  cp -r ./release-template/. ./${DATE_WITH_TIME}
  echo "https://github.com/doubtfire-lms/doubtfire-web/blob/${WEB_VERSION}/CHANGELOG.md" > ${DATE_WITH_TIME}/WEB_CHANGELOG.md
  echo "https://github.com/doubtfire-lms/doubtfire-api/blob/${API_VERSION}/CHANGELOG.md" > ${DATE_WITH_TIME}/API_CHANGELOG.md
  echo "https://github.com/doubtfire-lms/doubtfire-api/blob/${OVERSEER_VERSION}/CHANGELOG.md" > ${DATE_WITH_TIME}/OVERSEER_CHANGELOG.md

  echo
  echo "Please update release notes, and push them to origin before continuing here..."

  prepare_release 'doubtfire-deploy' "${APP_PATH}"
  DEPLOY_VERSION=$(git describe --abbrev=0 --tags)
done

echo
echo "### Step 4: Push releases"
echo

function push_release {
  PROJECT=$1
  PROJECT_PATH=$2

  cd "${PROJECT_PATH}"
  CURRENT_BRANCH=$(git branch --show-current)
  git push --follow-tags origin ${CURRENT_BRANCH}:releases
  if [ $? -ne 0 ]; then
    echo "Oh no... fix up this mess please";
    exit 1
  fi
}

echo "Push new releases to GitHub?"
select answer in "Skip" "Push"; do
    case $answer in
        Skip)
          echo "Not pushing releases"
          break;
          ;;
        Push)
          push_release 'doubtfire-web' "${APP_PATH}/doubtfire-web"
          push_release 'doubtfire-api' "${APP_PATH}/doubtfire-api"
          push_release 'doubtfire-overseer' "${APP_PATH}/doubtfire-overseer"
          push_release 'doubtfire-deploy' "${APP_PATH}"
          break;
          ;;
    esac
done

