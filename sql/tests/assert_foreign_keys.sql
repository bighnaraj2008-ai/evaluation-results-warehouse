-- =============================================================================
-- assert_foreign_keys.sql
-- Verify referential integrity across eval_results, eval_runs, and test_cases
-- =============================================================================
SELECT COUNT(*) AS orphaned_results_count
FROM eval_results e
LEFT JOIN eval_runs r ON r.run_id = e.run_id
LEFT JOIN test_cases t ON t.test_case_id = e.test_case_id
WHERE r.run_id IS NULL OR t.test_case_id IS NULL;