-- =============================================================================
-- category_breakdown.sql
-- Category-level granularity benchmark summary
-- =============================================================================
SELECT
    m.model_name,
    m.version AS model_version,
    tc.dataset_name,
    tc.category,
    COUNT(e.result_id) AS total_cases,
    SUM(CASE WHEN e.passed THEN 1 ELSE 0 END) AS passed_cases,
    AVG(e.score_accuracy) AS avg_accuracy,
    AVG(e.score_faithfulness) AS avg_faithfulness,
    AVG(e.score_latency_ms) AS avg_latency_ms
FROM eval_results e
JOIN eval_runs r ON r.run_id = e.run_id
JOIN models m ON m.model_id = r.model_id
JOIN test_cases tc ON tc.test_case_id = e.test_case_id
WHERE r.status = 'completed'
GROUP BY m.model_name, m.version, tc.dataset_name, tc.category
ORDER BY tc.dataset_name, tc.category, avg_accuracy DESC;