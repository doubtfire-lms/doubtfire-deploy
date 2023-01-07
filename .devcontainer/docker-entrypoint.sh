#!/usr/bin/env bash

echo "Starting Formatif development container..."

# Start the redis server
redis-server &

# Start mysql
sudo /workspace/.devcontainer/launch_db.sh mysqld &

exec "$@"
