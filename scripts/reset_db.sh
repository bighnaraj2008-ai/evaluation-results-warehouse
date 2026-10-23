#!/usr/bin/env bash
set -euo pipefail

DB_FILE="warehouse.db"
echo "Resetting warehouse database..."
rm -f "${DB_FILE}"
bash scripts/run_warehouse.sh
echo "Warehouse reset complete."