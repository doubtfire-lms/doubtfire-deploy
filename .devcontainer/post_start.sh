#!/bin/bash

echo 'Setting up git safe directories'
git config --global --add safe.directory /workspace/doubtfire-api
git config --global --add safe.directory /workspace/doubtfire-web
git config --global --add safe.directory /workspace

git config --global submodule.recurse false

if [[ $(pgrep -n mysqld) -ne 0 && $(pgrep -n redis-server) -ne 0 ]]; then
  echo 'Database and Redis are running'
else
  /workspace/.devcontainer/post_create.sh
fi
