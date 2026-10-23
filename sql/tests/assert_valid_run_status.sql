-- =============================================================================
-- assert_valid_run_status.sql
-- Verify all eval_runs records conform to allowable status values
-- =============================================================================
SELECT COUNT(*) AS violation_count
FROM eval_runs
WHERE status NOT IN ('pending', 'running', 'completed', 'failed');