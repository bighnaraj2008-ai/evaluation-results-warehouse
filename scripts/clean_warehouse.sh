#!/usr/bin/env bash
set -euo pipefail

DB_FILE="warehouse.db"
echo "Performing maintenance and pruning on ${DB_FILE}..."
sqlite3 "${DB_FILE}" < sql/utils/vacuum_analyze.sql
echo "Maintenance complete."