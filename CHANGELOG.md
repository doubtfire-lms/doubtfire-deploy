# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [5.0.5](https://github.com/macite/doubtfire-deploy/compare/v5.0.4...v5.0.5) (2021-12-07)


### Features

* add mail configuration options ([5c4189a](https://github.com/macite/doubtfire-deploy/commit/5c4189a3191281300205175e2b5aaaafef054743))


### Bug Fixes

* update actions in release script ([55e1d33](https://github.com/macite/doubtfire-deploy/commit/55e1d33804b6cad24be8a2d9cfecf0ef4bb2afd9))

### [5.0.4](https://github.com/macite/doubtfire-deploy/compare/v5.0.3...v5.0.4) (2021-12-06)


### Features

* add scheduled cron tasks for repeated actions ([2f9ca9c](https://github.com/macite/doubtfire-deploy/commit/2f9ca9c99ef71a5a1231e810a8a13e9c9b47441a))
* add scheduled tasks to PDFGen container ([442ebba](https://github.com/macite/doubtfire-deploy/commit/442ebbaf8bb2e9c278e63fa187c927afb0cb188e))
* enhance deployment handling of errors ([4661cd7](https://github.com/macite/doubtfire-deploy/commit/4661cd733e64a04461777a324b9b960fb08ba72d))

### [5.0.3](https://github.com/macite/doubtfire-deploy/compare/v5.0.2...v5.0.3) (2021-11-19)

### [5.0.2](https://github.com/macite/doubtfire-deploy/compare/v5.0.1...v5.0.2) (2021-11-19)

### [5.0.1](https://github.com/macite/doubtfire-deploy/compare/v5.0.0...v5.0.1) (2021-10-27)


### Bug Fixes

* trigger image builds on push to v tags ([dbd91ed](https://github.com/macite/doubtfire-deploy/commit/dbd91ed3c9f7a9435471fadc5186d9b3b60325ff))

## [5.0.0](https://github.com/macite/doubtfire-deploy/compare/v5.0.0-2...v5.0.0) (2021-10-13)


### Features

* add test publish script to aid in testing deployments ([94f7ea2](https://github.com/macite/doubtfire-deploy/commit/94f7ea2f881de832632e43aa343bff5f0a024c94))


### Bug Fixes

* correct links in dist compose for rabbit mq ([fb9d0c9](https://github.com/macite/doubtfire-deploy/commit/fb9d0c9ffecaadbe21e88bf8d5a5ef65722ec239))
* ignore data in dist folder and ensure db container script is executable ([ba71fd0](https://github.com/macite/doubtfire-deploy/commit/ba71fd0ef2dd83d301a5b91184f894074dc94f9c))
* push to version branch and fix syntax error in release script ([3244b51](https://github.com/macite/doubtfire-deploy/commit/3244b516e488d95bb63671bc0b6b5d811344976f))

## [5.0.0-2](https://github.com/macite/doubtfire-deploy/compare/v5.0.0-1...v5.0.0-2) (2021-08-09)


### Bug Fixes

* correct syntax error in release script ([b88a836](https://github.com/macite/doubtfire-deploy/commit/b88a8362fe3700244fd2da17fe9dc5badf03f69e))
* correct tag name in dist docker compose ([db4549f](https://github.com/macite/doubtfire-deploy/commit/db4549f82c97eb710a132e69e0440ea0c10fface))

## [5.0.0-1](https://github.com/macite/doubtfire-deploy/compare/v4.0.0...v5.0.0-1) (2021-08-06)


### Features

* add ability to run deploy workflow from release ([1294c8f](https://github.com/macite/doubtfire-deploy/commit/1294c8f1355a5e95fa901b6ac2241d6097a8b0e3))
* Add docker compose for deployment ([7890b1f](https://github.com/macite/doubtfire-deploy/commit/7890b1f1c7b356324b0c39308c9dcd522018b39b))
* add release and branch creation scripts ([b2911e7](https://github.com/macite/doubtfire-deploy/commit/b2911e71e18769752782022fc49e363afe1b17a7))
* Add scripts to assist setting up production ([591392b](https://github.com/macite/doubtfire-deploy/commit/591392be0ca3b32117aa587f646eea88c42ba926))
* introduce overseer docker image ([53db4ef](https://github.com/macite/doubtfire-deploy/commit/53db4ef2a89646e9222bbf682fe7f8204892c866))
* introduce release script to simplify build and release process ([1bd04e6](https://github.com/macite/doubtfire-deploy/commit/1bd04e69aafe064201f7a11a1fbe30a9e92a92c2))
* Remove database and add watchtower to dist compose ([c2b0101](https://github.com/macite/doubtfire-deploy/commit/c2b0101822ac8fe27044af30f5410ec2a7fdc569))


### Bug Fixes

* Add context to webserver build ([9fbf398](https://github.com/macite/doubtfire-deploy/commit/9fbf398ad2b87cc24dc08945a15808fd94b01202))
* Add missing with in checkout action ([351bb90](https://github.com/macite/doubtfire-deploy/commit/351bb90dc95b99936f612ee0d2aacf79fdaf8557))
* Add setup buildx and try different file and context for build ([3baf3d7](https://github.com/macite/doubtfire-deploy/commit/3baf3d7a7a2a080000f595ea9ab8d3ebef9e91a2))
* add the env to the github action ([9361c60](https://github.com/macite/doubtfire-deploy/commit/9361c60b4f811954e2aad4b07d179c7d8001ecc0))
* Adjust context for docker build ([f6d105f](https://github.com/macite/doubtfire-deploy/commit/f6d105fb09bd6305bfb4d669659960a8601083df))
* correct comma use in bash script parameters ([c8c2d0f](https://github.com/macite/doubtfire-deploy/commit/c8c2d0f953280183f475c123581869cd773ab59c))
* Correct meta for docker and redo npm install ([bec78b6](https://github.com/macite/doubtfire-deploy/commit/bec78b6bbdfcd34cce5a6e3977ca0b79dde95818))
* Correct path to pdfGen dockerfile ([db6f29c](https://github.com/macite/doubtfire-deploy/commit/db6f29c7915523dec075c25fb49f613e85107545))
* Correct typo in pdfgen image name ([370ed89](https://github.com/macite/doubtfire-deploy/commit/370ed892ce7f22a4cac8c7c38428635a3f9d62ea))
* Ensure build errors end build process ([ad3a995](https://github.com/macite/doubtfire-deploy/commit/ad3a995608e7bc78d0bcbfdb1446b6817eac56b5))
* ensure remote only asked for once ([e39aa2a](https://github.com/macite/doubtfire-deploy/commit/e39aa2a4d588ae6f3b8d4d70fdfe4f7895709a91))
* pull submodules correctly on ghactions ([97c8a07](https://github.com/macite/doubtfire-deploy/commit/97c8a0724a50569ce512001ccdc4e225566264d2))
* Reinstate webserver build on push ([70d125d](https://github.com/macite/doubtfire-deploy/commit/70d125dc444f4ed7e583d23b6be82de64534b367))
* switch build to use docker compose in place of docker-compose ([0fcd126](https://github.com/macite/doubtfire-deploy/commit/0fcd12685b0ea0f62a16adbb91280ef2bd6e60c0))
* Switch to use token for dockerhub login ([a087b55](https://github.com/macite/doubtfire-deploy/commit/a087b556f5376f07b535866190d437fbefd51417))
* syntax error in ga build config ([d3d2925](https://github.com/macite/doubtfire-deploy/commit/d3d29255e1790fbdf0ac040d83c5731a4834dcd1))
* update docker meta ([b932e00](https://github.com/macite/doubtfire-deploy/commit/b932e009eafe2d6ce87e3e49f6b1333571dcb9b2))
* Update doubtfire-web ([301056f](https://github.com/macite/doubtfire-deploy/commit/301056f2a80e14802020c22abbb676e7d1b1153b))
* update submodule pull method in ghactions ([cefced7](https://github.com/macite/doubtfire-deploy/commit/cefced7e8b4a28482587a045396179bf2183ee7f))
* use correct docker_meta tag in push config ([9db97b6](https://github.com/macite/doubtfire-deploy/commit/9db97b6ad7874cd67cba5eb5f5f1bdfe2e75f85c))
* use https for branch origin ([63a92a0](https://github.com/macite/doubtfire-deploy/commit/63a92a0cadc3ebb3a6a3a5ffb2c3c9424195eb9b))

## 1.0.0 (2021-06-03)


### Bug Fixes

* add the env to the github action ([9361c60](https://github.com/doubtfire-lms/doubtfire-deploy/commit/9361c60b4f811954e2aad4b07d179c7d8001ecc0))
* pull submodules correctly on ghactions ([97c8a07](https://github.com/doubtfire-lms/doubtfire-deploy/commit/97c8a0724a50569ce512001ccdc4e225566264d2))
* syntax error in ga build config ([d3d2925](https://github.com/doubtfire-lms/doubtfire-deploy/commit/d3d29255e1790fbdf0ac040d83c5731a4834dcd1))
* Update doubtfire-web ([301056f](https://github.com/doubtfire-lms/doubtfire-deploy/commit/301056f2a80e14802020c22abbb676e7d1b1153b))
* update submodule pull method in ghactions ([cefced7](https://github.com/doubtfire-lms/doubtfire-deploy/commit/cefced7e8b4a28482587a045396179bf2183ee7f))
