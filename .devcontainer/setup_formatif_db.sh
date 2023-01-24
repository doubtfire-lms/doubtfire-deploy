#!/bin/bash

# Wait for mysql to start
delay 5

if [[ "`mysql --user=root --password="${MYSQL_ROOT_PASSWORD}" -qfsBNe "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MYSQL_DATABASE}';" 2>&1`" -gt 0 ]];
then
  echo "Database already exists"
else
  echo "Creating and populating database"
  cd /workspace/doubtfire-api
  bundle exec rake db:populate

  echo "Simulating sign off"
  bundle exec rake db:simulate_signoff
fi
