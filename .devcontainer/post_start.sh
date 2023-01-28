#!/bin/bash

echo 'Setting up git safe directories'
git config --global --add safe.directory /workspace/doubtfire-api
git config --global --add safe.directory /workspace/doubtfire-web
git config --global --add safe.directory /workspace

