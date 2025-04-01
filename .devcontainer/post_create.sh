#!/bin/bash

echo 'Setting up zshrc, p10k, and irb history'
ln -sf /workspace/.devcontainer/.zshrc $HOME
ln -s /workspace/.devcontainer/.p10k.zsh $HOME
ln -s /workspace/.devcontainer/.irbrc $HOME


sudo chown vscode:vscode /var/lib/mysql
sudo chown vscode:vscode /var/run/docker.sock
# sudo chmod a+rw /var/lib/mysql
sudo chmod a+rw /workspace/tmp
sudo chmod a+rw /workspace/node_modules
#sudo chmod a+rw /student-work
sudo chown vscode:vscode /student-work
sudo chmod a+rw /workspace/doubtfire-web/node_modules
sudo chmod a+rw /home/vscode/.gems

echo 'Starting Services'
/workspace/.devcontainer/docker-entrypoint.sh echo "Done"
