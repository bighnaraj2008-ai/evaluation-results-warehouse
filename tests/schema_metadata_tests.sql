-- =============================================================================
-- tests/schema_metadata_tests.sql
-- Database catalog metadata verification query
-- =============================================================================
SELECT name, type
FROM sqlite_master
WHERE type IN ('table', 'view', 'index')
ORDER BY type, name;