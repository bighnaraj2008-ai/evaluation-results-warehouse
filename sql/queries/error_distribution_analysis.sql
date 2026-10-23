-- =============================================================================
-- error_distribution_analysis.sql
-- Breakdown of failed test cases, policy violations, and error details
-- =============================================================================
SELECT
    m.model_name,
    m.version AS model_version,
    r.dataset_name,
    tc.category,
    e.test_case_id,
    e.score_accuracy,
    e.score_faithfulness,
    e.error_details
FROM eval_results e
JOIN eval_runs r ON r.run_id = e.run_id
JOIN models m ON m.model_id = r.model_id
JOIN test_cases tc ON tc.test_case_id = e.test_case_id
WHERE e.passed = 0
ORDER BY m.model_name, r.dataset_name, e.test_case_id;