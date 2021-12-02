#!/bin/sh

# Ensure log is present
touch /var/log/cron.log
# Setup crontab
crontab /etc/cron.d/container_cronjob
# Run cron and follow log
chmod 644 /etc/cron.d/container_cronjob && cron && tail -f /var/log/cron.log”
