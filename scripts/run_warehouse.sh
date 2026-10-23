#!/usr/bin/env bash
set -euo pipefail

DB_FILE="warehouse.db"
echo "Initializing SQLite Evaluation Results Warehouse: ${DB_FILE}..."

sqlite3 "${DB_FILE}" < sql/schema/001_eval_warehouse.sql
sqlite3 "${DB_FILE}" < sql/schema/002_test_cases.sql
sqlite3 "${DB_FILE}" < sql/schema/003_prompt_templates.sql

echo "Loading seed fixtures..."
for seed in sql/seeds/*.sql; do
    echo "  Applying ${seed}..."
    sqlite3 "${DB_FILE}" < "${seed}"
done

echo "Creating analytical views..."
for view in sql/views/*.sql; do
    echo "  Applying ${view}..."
    sqlite3 "${DB_FILE}" < "${view}"
done

echo "Warehouse ready!"