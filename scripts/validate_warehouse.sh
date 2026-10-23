#!/usr/bin/env bash
set -euo pipefail

DB_FILE="warehouse.db"
echo "Validating warehouse integrity..."
sqlite3 "${DB_FILE}" "PRAGMA foreign_key_check;"
sqlite3 "${DB_FILE}" "PRAGMA integrity_check;"
echo "Integrity verification passed."