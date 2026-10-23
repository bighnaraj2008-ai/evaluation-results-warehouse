#!/usr/bin/env bash
set -euo pipefail

DB_FILE="warehouse.db"
OUTPUT_DIR="reports"
mkdir -p "${OUTPUT_DIR}"

echo "Exporting leaderboard summary to CSV..."
sqlite3 -header -csv "${DB_FILE}" < sql/queries/eval_summary_leaderboard.sql > "${OUTPUT_DIR}/leaderboard_$(date +%Y%m%d).csv"
echo "Export saved to ${OUTPUT_DIR}."