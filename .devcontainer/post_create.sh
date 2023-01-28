#!/bin/bash

echo 'Setting up zshrc and p10k'
cp .devcontainer/.zshrc $HOME
cp .devcontainer/.p10k.zsh $HOME

echo 'Granting access to student work'
sudo find /student-work/* -exec chmod a+rw {} \; &

echo 'Starting Services'
/workspace/.devcontainer/docker-entrypoint.sh echo "Done"
