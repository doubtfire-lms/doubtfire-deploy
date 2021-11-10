# Base development docker images

This folder contains dockerfiles used to create and deploy images to docker hub for the development containers.

1. `./build.sh`

   - this will create doubtfire-api:VERSION-dev and doubtfire-web:VERSION-dev images where VERSION is based on the branch name
   - test locally to ensure things work as you expect

2. `./publish.sh`

   - things should now be available for others to use
