#!/usr/bin/env bash
set -euo pipefail

DB_FILE="warehouse.db"
echo "Benchmarking analytical query workloads..."
for q in sql/queries/*.sql; do
    echo "Query plan for ${q}:"
    sqlite3 "${DB_FILE}" "EXPLAIN QUERY PLAN $(cat ${q})"
done