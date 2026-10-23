-- =============================================================================
-- scripts/health_check.sql
-- Database diagnostic health check script
-- =============================================================================
SELECT
    status,
    COUNT(*) AS run_count
FROM eval_runs
GROUP BY status;