#!/bin/bash

APP_PATH=`echo $0 | awk '{split($0,patharr,"/"); idx=1; while(patharr[idx+1] != "") { if (patharr[idx] != "/") {printf("%s/", patharr[idx]); idx++ }} }'`
APP_PATH=`cd "$APP_PATH"; pwd`

cd "${APP_PATH}"

echo "## Generate Release Notes and Push to Release Branch"

echo
echo "### Step 1: Check we are ready... requires repository to track remote branches"
echo

cd "${APP_PATH}"
"${APP_PATH}/check.sh"

if [ $? -ne 0 ]; then
  echo "Ensure that everything is clean and ready to go!";
  exit 1
fi

echo
echo "### Step 2. Update version tags"
echo

echo "Doubtfire is at version `git describe --abbrev=0 --tags`"

# default skip version update to false
SKIP=0

select answer in "Skip" "Auto" "Major" "Minor" "Patch"; do
  case $answer in
    Skip)
      SKIP=1
      break;
      ;;
    Auto)
      RELEASE_AS=
      break;
      ;;
    Major)
      RELEASE_AS="--release-as major"
      break;
      ;;
    Minor)
      RELEASE_AS="--release-as minor"
      break;
      ;;
    Patch)
      RELEASE_AS="--release-as patch"
      break;
      ;;
  esac
done

function prepare_release {
  local PROJECT=$1
  local PROJECT_PATH=$2
  local __resultvar=$3

  echo "Preparing ${PROJECT} release at ${PROJECT_PATH}"

  cd "${PROJECT_PATH}"

  CURRENT_TAG=$(git describe --exact-match --tags 2>>/dev/null)

  if [ $CURRENT_TAG ]; then
    echo "$PROJECT is currently on tag $CURRENT_TAG"
    echo "Do you want to create a new release for this project?"

    select answer in "No" "Yes"; do
      case $answer in
        No)
          eval $__resultvar="'$CURRENT_TAG'"
          return 0
          ;;
        Yes)
          break;
          ;;
      esac
    done
  fi

  RELEASE_VERSION=$(npx standard-version $RELEASE_AS --dry-run  | grep "tagging release " | sed 's/^.* release //')

  CURRENT_BRANCH=$(git branch --show-current)
  TRUNC_RELEASE=${RELEASE_VERSION#v}

  while [ ${CURRENT_BRANCH%.x} != ${TRUNC_RELEASE%.*} ]; do
    echo "$PROJECT does not match release branch naming: ${CURRENT_BRANCH%.x} != ${TRUNC_RELEASE%.*}"
    read -p "Fix then press enter to continue (or break to quit)"

    CURRENT_BRANCH=$(git branch --show-current)
    RELEASE_VERSION=$(npx standard-version --dry-run -r $RELEASE_AS  | grep "tagging release " | sed 's/^.* release //')
    TRUNC_RELEASE=${RELEASE_VERSION#v}
  done

  echo "We will update ${PROJECT} to ${RELEASE_VERSION}. Proceed?"
  select answer in "No" "Yes"; do
    case $answer in
      No)
        exit -1
        ;;
      Yes)
        break
        ;;
    esac
  done

  eval $__resultvar="'$RELEASE_VERSION'"
}

function do_release {
  PROJECT=$1
  PROJECT_PATH=$2

  cd "${PROJECT_PATH}"

  npx standard-version $RELEASE_AS
}

prepare_release 'doubtfire-web' "${APP_PATH}/doubtfire-web" WEB_VERSION
prepare_release 'doubtfire-api' "${APP_PATH}/doubtfire-api" API_VERSION
# prepare_release 'doubtfire-overseer' "${APP_PATH}/doubtfire-overseer" OVERSEER_VERSION
prepare_release 'doubtfire-deploy' "${APP_PATH}" DEPLOY_VERSION

echo "All projects are now ready. Proceed to create tagged commits?"

select answer in "No" "Yes"; do
  case $answer in
    No)
      exit 1
      ;;
    Yes)
      break;
      ;;
  esac
done


do_release 'doubtfire-web' "${APP_PATH}/doubtfire-web"
do_release 'doubtfire-api' "${APP_PATH}/doubtfire-api"
# do_release 'doubtfire-overseer' "${APP_PATH}/doubtfire-overseer"

echo
echo "### Step 3: Prepare deploy for release"
echo

cd "${APP_PATH}/releases"
mkdir -p $DEPLOY_VERSION
echo "$API_VERSION" > "${DEPLOY_VERSION}/.apiversion"
echo "$WEB_VERSION" > "${DEPLOY_VERSION}/.webversion"
# echo "$OVERSEER_VERSION" > "${DEPLOY_VERSION}/.overseer"
cp -r ./release-template/. ./${DEPLOY_VERSION}
echo "https://github.com/doubtfire-lms/doubtfire-web/blob/${WEB_VERSION}/CHANGELOG.md" > ${DEPLOY_VERSION}/WEB_CHANGELOG.md
echo "https://github.com/doubtfire-lms/doubtfire-api/blob/${API_VERSION}/CHANGELOG.md" > ${DEPLOY_VERSION}/API_CHANGELOG.md
# echo "https://github.com/doubtfire-lms/doubtfire-overseer/blob/${OVERSEER_VERSION}/CHANGELOG.md" > ${DEPLOY_VERSION}/OVERSEER_CHANGELOG.md

echo
echo "Please update release notes and commit before continuing..."

read -p "Press enter to continue" TEMP

do_release 'doubtfire-deploy' "${APP_PATH}"

echo
echo "### Step 4: Push releases"
echo

function push_release {
  local PROJECT=$1
  local PROJECT_PATH=$2
  local REMOTE=$3

  cd "${PROJECT_PATH}"
  CURRENT_BRANCH=$(git branch --show-current)
  git push --follow-tags $REMOTE ${CURRENT_BRANCH}
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
      echo "What's the name of the remote to push to (doubtfire-lms)"
      read -p "Remote: (eg origin/upstream): " REMOTE

      push_release 'doubtfire-web' "${APP_PATH}/doubtfire-web" $REMOTE
      push_release 'doubtfire-api' "${APP_PATH}/doubtfire-api" $REMOTE
      # push_release 'doubtfire-overseer' "${APP_PATH}/doubtfire-overseer" $REMOTE
      push_release 'doubtfire-deploy' "${APP_PATH}" $REMOTE

      break;
      ;;
  esac
done
