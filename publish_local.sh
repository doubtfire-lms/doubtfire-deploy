#!/bin/sh

echo "WARNING: Do not use this to publish release versions. This does not ensure that the release will be repeatable."
echo "         For production releases please use 'release.sh'."
echo

select answer in "Proceed" "Quit"; do
  case $answer in
    Quit)
      exit 1;
      ;;
    Proceed)
      break;
      ;;
  esac
done

read -p "What is your docker hub username: " DH_USER
read -sp "What is ${DH_USER}'s docker hub password: " PASSWORD
echo $PASSWORD | docker login -u "$DH_USER" --password-stdin
PASSWORD=""

APP_PATH=`echo $0 | awk '{split($0,patharr,"/"); idx=1; while(patharr[idx+1] != "") { if (patharr[idx] != "/") {printf("%s/", patharr[idx]); idx++ }} }'`
APP_PATH=`cd "$APP_PATH"; pwd`

cd "${APP_PATH}"

echo "Creating webserver image to build web distribution"
cd "./doubtfire-web"
docker image build --no-cache --rm --tag doubtfire-web:local .

echo "Generate web application to doubtfire-web/dist"
docker run -it -v "${APP_PATH}/doubtfire-web":/doubtfire-web -v "${APP_PATH}/doubtfire-web/dist":/doubtfire-web/dist --workdir /doubtfire-web doubtfire-web:local npm run-script deploy

echo
echo "------------------------------------------------------------------------------"
echo

echo "Generating ${DH_USER}/webserver:test image"
cd "${APP_PATH}"
docker image build --no-cache --rm --tag "${DH_USER}/webserver:test" -f webserver.Dockerfile .

echo "Publishing ${DH_USER}/webserver:test image"
docker push "${DH_USER}/webserver:test"

echo
echo "------------------------------------------------------------------------------"
echo

echo "Generating PDF Gen"
echo "Generating ${DH_USER}/pdfgen:test image"
docker image build --no-cache --rm --tag "${DH_USER}/pdfgen:test" -f pdfgen.Dockerfile .

echo "Publishing ${DH_USER}/pdfGen:test image"
docker push "${DH_USER}/pdfGen:test"

echo
echo "------------------------------------------------------------------------------"
echo

echo "Generating Overseer"
echo "Generating ${DH_USER}/overseer:test image"
docker image build --no-cache --rm --tag "${DH_USER}/overseer:test" -f overseer.Dockerfile .

echo "Publishing ${DH_USER}/overseer:test image"
docker push "${DH_USER}/overseer:test"

