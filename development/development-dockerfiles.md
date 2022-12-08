# Development docker images

This folder contains docker compose files, and scripts to build the associated container images from the api and web projects.

## Running in development

Use docker compose to run the api and web projects in development mode. See details in [CONTRIBUTING.md](../CONTRIBUTING.md)

## Building new container images

When you adjust the configuration of the api or web container, you will need to rebuild the container images to ensure the changes are available to yourself and others.

1. Make changes to the configuration as required. This can include:

   - adding new gems to the api
   - changing the Dockerfiles

      - [../doubtfire-api/Dockerfile](../doubtfire-api/Dockerfile)
      - [../doubtfire-web/Dockerfile](../doubtfire-web/Dockerfile)
      - Make sure to also reflect changes in:   
         - [../doubtfire-api/deployApi.Dockerfile](../doubtfire-api/deployApi.Dockerfile)
         - [../doubtfire-api/deployAppSvr.Dockerfile](../doubtfire-api/deployAppSvr.Dockerfile)
         - [../doubtfire-web/Dockerfile.dev](../doubtfire-web/deploy.Dockerfile)

1. Adjust versions to ensure existing images are not overwritten

   - [`version.sh`](version.sh) contains the version number used to tag images. Update the api or web version number as appropriate.
   - Docker compose files uses the tag to indicate which images to use for the web and api containers. Update the tag to match the version number in the following files:

      - [`docker-compose.yml`](docker-compose.yml) 
      - [`docker-compose.full.yml`](docker-compose.full.yml)
      - [`../doubtfire-web/docker-compose.yml`](../doubtfire-web/docker-compose.yml)

1. Run `./build.sh` and test locally

   - this will create doubtfire-api:VERSION-dev and doubtfire-web:VERSION-dev images where VERSION is specified in `version.sh`
   - test locally to ensure things work as you expect

1. Run `./publish.sh` to publish the images to docker hub

   - things should now be available for others to use
