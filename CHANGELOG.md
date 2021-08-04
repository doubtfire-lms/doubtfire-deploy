# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [](https://github.com/macite/doubtfire-deploy/compare/v4.0.0...v) (2021-08-04)


### Features

* Add docker compose for deployment ([7890b1f](https://github.com/macite/doubtfire-deploy/commit/7890b1f1c7b356324b0c39308c9dcd522018b39b))
* add release and branch creation scripts ([b2911e7](https://github.com/macite/doubtfire-deploy/commit/b2911e71e18769752782022fc49e363afe1b17a7))
* add script to change remotes of submodules ([126cc54](https://github.com/macite/doubtfire-deploy/commit/126cc54a0905040a263573b359b16ac4107eb38e))
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
* correct comparison of the release and current branch names ([fb5ce09](https://github.com/macite/doubtfire-deploy/commit/fb5ce09080543d037e2e30cc7ffd94773ae9dcdd))
* correct issue with release script use of select ([af4a6a0](https://github.com/macite/doubtfire-deploy/commit/af4a6a012948523de2033512df5ecee32e3ef47c))
* Correct meta for docker and redo npm install ([bec78b6](https://github.com/macite/doubtfire-deploy/commit/bec78b6bbdfcd34cce5a6e3977ca0b79dde95818))
* Correct path to pdfGen dockerfile ([db6f29c](https://github.com/macite/doubtfire-deploy/commit/db6f29c7915523dec075c25fb49f613e85107545))
* Correct typo in pdfgen image name ([370ed89](https://github.com/macite/doubtfire-deploy/commit/370ed892ce7f22a4cac8c7c38428635a3f9d62ea))
* correct use of while in branch test ([4eb167d](https://github.com/macite/doubtfire-deploy/commit/4eb167dc03c7f3fd22fcd17250f34563de12f405))
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
