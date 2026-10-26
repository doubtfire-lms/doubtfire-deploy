#!/bin/bash

set -euo pipefail

# Pause new Sidekiq and portfolio-generation work before restarting API services.
# In-progress jobs continue, and both queues resume when their services restart.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/docker-compose.yml" ]; then
  PRODUCTION_DIR="$SCRIPT_DIR"
elif [ -f "$(dirname "$SCRIPT_DIR")/docker-compose.yml" ]; then
  PRODUCTION_DIR="$(dirname "$SCRIPT_DIR")"
else
  echo "Could not find docker-compose.yml beside this script or in its parent directory. Exiting."
  exit 1
fi

COMPOSE=(docker compose --project-directory "$PRODUCTION_DIR" -f "$PRODUCTION_DIR/docker-compose.yml")

echo "Pausing both Sidekiq queues..."
"${COMPOSE[@]}" exec apiserver bash -c "cd /doubtfire && rails runner 'Sidekiq::ProcessSet.new.each(&:quiet!)'"
echo "Sidekiq queues have been paused. Restart sidekiq to continue"

echo "Pausing Pdfgen cron jobs..."
if "${COMPOSE[@]}" exec pdfgen bash -c "crontab -l >/dev/null 2>&1"; then
  "${COMPOSE[@]}" exec pdfgen bash -c "crontab -r"
  echo "Pdfgen cron jobs have been paused"
else
  echo "Pdfgen cron jobs are already paused"
fi

# Monitor api/tmp/latex-pdfgen for remaining work before restarting services.
