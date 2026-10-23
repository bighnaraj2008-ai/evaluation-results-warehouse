#!/usr/bin/env bash
set -euo pipefail

# Sample Slack incoming webhook notification script
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-https://hooks.slack.com/services/EXAMPLE}"
MESSAGE="*Evaluation Warehouse Alert*: Regression detected in latest benchmark run."

curl -s -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"${MESSAGE}\"}" \
    "${SLACK_WEBHOOK_URL}" || true
echo "Alert dispatched to Slack."