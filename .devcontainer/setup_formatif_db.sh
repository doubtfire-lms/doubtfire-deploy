#!/bin/bash

# Wait for mysql to start
check_process() {
  [ "$1" = "" ] && return 0
  [ $(pgrep -n $1) ] && return 1 || return 0
}

check_process "mysqld"
CHECK_RET=$?
if [ $CHECK_RET -eq 0 ]; then # none exist
  echo 'Waiting for mysqld to start'
  sleep 5
fi

check_process "mysqld"
CHECK_RET=$?
if [ $CHECK_RET -eq 0 ]; then # none exist
  echo 'Failed to find mysqld - please make sure the database is running'
  exit 1
fi

NEXT_WAIT_TIME=0
# Loop until mysqld is ready...
while true; do
  RESP=`mysql --user=root --password="${MYSQL_ROOT_PASSWORD}" -qfsBNe "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MYSQL_DATABASE}';" 2>>/dev/null`

  if [ $? -ne 0 ]; then
    if [ $NEXT_WAIT_TIME -eq 0 ]; then
      echo -n "Waiting for access to mysql..."
    fi

    # Check mysqld is still running...
    check_process "mysqld"
    CHECK_RET=$?
    if [ $CHECK_RET -eq 0 ]; then # none exist
      echo "x"
      echo "Mysqld has stopped... unable to check and create database"
      exit 1
    fi

    if [ $NEXT_WAIT_TIME -ge 10 ]; then
      echo "x"
      echo "Unable to connect to mysql after $NEXT_WAIT_TIME retries"
      exit 1
    fi

    echo -n "."
    sleep $(( NEXT_WAIT_TIME++ ))
  else
    echo "!"
    break
  fi
done

if [[ $RESP -gt 0 ]]; then
  echo "Database already exists"
else
  echo "Creating and populating database - do not shutdown!"
  cd /workspace/doubtfire-api

  bundle exec rake db:populate
  echo "Database created - you can open another terminal while this completes if you want.."

  echo "Simulating sign off in the background"
  (
    bundle exec rake db:simulate_signoff >>/workspace/tmp/database_populate.log 2>>/workspace/tmp/database_populate.log
    rm /workspace/tmp/database_populate.log
  )&
fi
