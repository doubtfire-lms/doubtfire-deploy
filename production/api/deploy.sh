#!/bin/bash

# Production: Wait up to as long as 30 minutes for deploying
# PDFGEN_DRAIN_TIMEOUT_SECONDS=1800 SIDEKIQ_DRAIN_TIMEOUT_SECONDS=1800 DRAIN_POLL_INTERVAL_SECONDS=15 ./api/deploy.sh

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PRODUCTION_DIR="$(dirname "$SCRIPT_DIR")"
COMPOSE=(docker compose --project-directory "$PRODUCTION_DIR" -f "$PRODUCTION_DIR/docker-compose.yml")
SUPPORT_SERVICES=(texlive texlive-pdfgen jplag gotenberg lti)

# DO NOT DEPLOY VIA THIS SCRIPT IF NEW VERSION OF ONTRACK'S API REQUIRES MIGRATIONS

# 1. Set the latest version of the api in .env
# 2. Uncomment the apiserver-green service
# 3. Run this script
# 4. Comment out the apiserver-green service so that it doesn't boot on server restart

PDFGEN_DRAIN_TIMEOUT_SECONDS="${PDFGEN_DRAIN_TIMEOUT_SECONDS:-1800}"
SIDEKIQ_DRAIN_TIMEOUT_SECONDS="${SIDEKIQ_DRAIN_TIMEOUT_SECONDS:-1800}"
DRAIN_POLL_INTERVAL_SECONDS="${DRAIN_POLL_INTERVAL_SECONDS:-10}"
APISERVER_HEALTH_TIMEOUT_SECONDS="${APISERVER_HEALTH_TIMEOUT_SECONDS:-120}"
APISERVER_HEALTH_POLL_INTERVAL_SECONDS="${APISERVER_HEALTH_POLL_INTERVAL_SECONDS:-2}"

if ! "${COMPOSE[@]}" config --services | grep -Fx "apiserver-green" > /dev/null; then
  echo "Service 'apiserver-green' does not exist. Did you remember to uncomment it? Exiting."
  exit 1
fi

wait_for_pdfgen_to_drain() {
  local timeout="$1"
  local interval="$2"
  local start
  local elapsed
  local remaining

  start=$(date +%s)

  while true; do
    remaining=$(
      "${COMPOSE[@]}" exec -T apiserver bundle exec rails runner '
        queued = Project.where(compile_portfolio: true).count
        active = Project.where.not(portfolio_generation_pid: nil).count
        puts queued + active
      '
    )

    echo "PDF generation work remaining: ${remaining}"

    if [ "${remaining}" = "0" ]; then
      return 0
    fi

    elapsed=$(( $(date +%s) - start ))
    if [ "$elapsed" -ge "$timeout" ]; then
      echo "Timed out waiting for PDF generation to drain after ${timeout}s."
      exit 1
    fi

    sleep "$interval"
  done
}

wait_for_sidekiq_workers_to_finish() {
  local timeout="$1"
  local interval="$2"
  local start
  local elapsed
  local active

  start=$(date +%s)

  while true; do
    active=$(
      "${COMPOSE[@]}" exec -T apiserver bundle exec rails runner '
        require "sidekiq/api"
        require "json"

        active = Sidekiq::Workers.new.count do |_process_id, _thread_id, work|
          payload = work["payload"].is_a?(String) ? JSON.parse(work["payload"]) : work["payload"]

          # Count all actively running jobs.
          payload.present?
        end

        puts active
      '
    )

    echo "Active Sidekiq jobs remaining: ${active}"

    if [ "${active}" = "0" ]; then
      return 0
    fi

    elapsed=$(( $(date +%s) - start ))
    if [ "$elapsed" -ge "$timeout" ]; then
      echo "Timed out waiting for active Sidekiq jobs to finish after ${timeout}s."
      exit 1
    fi

    sleep "$interval"
  done
}

wait_for_apiserver_health() {
  local name="$1"
  local timeout="$2"
  local interval="$3"
  local start
  local elapsed

  start=$(date +%s)

  while true; do
    if "${COMPOSE[@]}" exec -T "$name" \
      curl --fail --silent --max-time 5 http://127.0.0.1:3000/health \
      > /dev/null 2>&1; then
      echo "${name} is healthy."
      return 0
    fi

    elapsed=$(( $(date +%s) - start ))
    if [ "$elapsed" -ge "$timeout" ]; then
      echo "Timed out waiting for ${name} to become healthy after ${timeout}s."
      exit 1
    fi

    echo "Waiting for ${name} to become healthy..."
    sleep "$interval"
  done
}

"${COMPOSE[@]}" pull

"$SCRIPT_DIR/pause-pdfgen.sh"

# Wait for any in-flight LaTeX/portfolio work to finish before stopping pdfgen.
wait_for_pdfgen_to_drain "$PDFGEN_DRAIN_TIMEOUT_SECONDS" "$DRAIN_POLL_INTERVAL_SECONDS"

# Wait for Sidekiq jobs such as portfolio zip compression to finish before stopping sidekiq.
wait_for_sidekiq_workers_to_finish "$SIDEKIQ_DRAIN_TIMEOUT_SECONDS" "$DRAIN_POLL_INTERVAL_SECONDS"

sleep 5

"${COMPOSE[@]}" down pdfgen
"${COMPOSE[@]}" down sidekiq

sleep 5

"${COMPOSE[@]}" up apiserver-green -d --force-recreate

wait_for_apiserver_health \
  "apiserver-green" \
  "$APISERVER_HEALTH_TIMEOUT_SECONDS" \
  "$APISERVER_HEALTH_POLL_INTERVAL_SECONDS"

sleep 5

"${COMPOSE[@]}" up -d --force-recreate "${SUPPORT_SERVICES[@]}"

sleep 5

"${COMPOSE[@]}" down apiserver
"${COMPOSE[@]}" up apiserver -d

wait_for_apiserver_health \
  "apiserver" \
  "$APISERVER_HEALTH_TIMEOUT_SECONDS" \
  "$APISERVER_HEALTH_POLL_INTERVAL_SECONDS"

sleep 5

"${COMPOSE[@]}" down apiserver-green

sleep 5

"${COMPOSE[@]}" up pdfgen -d
"${COMPOSE[@]}" up sidekiq -d
