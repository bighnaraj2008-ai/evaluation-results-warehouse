#!/usr/bin/env bash
set -euo pipefail

DB_FILE="warehouse.db"
echo "Running SQL Assertion Test Suite against ${DB_FILE}..."

FAILURES=0
for test_file in sql/tests/*.sql; do
    echo -n "  Running ${test_file}... "
    COUNT=$(sqlite3 "${DB_FILE}" < "${test_file}")
    if [ "${COUNT}" -eq 0 ]; then
        echo "PASS"
    else
        echo "FAIL (violations: ${COUNT})"
        FAILURES=$((FAILURES + 1))
    fi
done

if [ "${FAILURES}" -gt 0 ]; then
    echo "Test suite failed with ${FAILURES} failure(s)."
    exit 1
fi

echo "All SQL schema assertion tests passed successfully."