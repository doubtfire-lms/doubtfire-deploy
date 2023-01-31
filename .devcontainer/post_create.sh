#!/bin/bash

echo 'Setting up zshrc, p10k, and irb history'
ln -sf /workspace/.devcontainer/.zshrc $HOME
ln -s /workspace/.devcontainer/.p10k.zsh $HOME
ln -s /workspace/.devcontainer/.irbrc $HOME

echo 'Granting access to student work in the background'
sudo find /student-work/* -exec chmod a+rw {} \; &

echo 'Starting Services'
/workspace/.devcontainer/docker-entrypoint.sh echo "Done"
