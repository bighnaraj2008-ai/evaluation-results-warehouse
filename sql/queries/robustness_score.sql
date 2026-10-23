-- =============================================================================
-- robustness_score.sql
-- Cross-run variance and quality stability score
-- =============================================================================
SELECT
    m.model_name,
    r.dataset_name,
    COUNT(DISTINCT r.run_id) AS total_runs,
    AVG(e.score_accuracy) AS mean_accuracy,
    MAX(e.score_accuracy) - MIN(e.score_accuracy) AS accuracy_range,
    AVG(e.score_latency_ms) AS mean_latency
FROM eval_results e
JOIN eval_runs r ON r.run_id = e.run_id
JOIN models m ON m.model_id = r.model_id
WHERE r.status = 'completed'
GROUP BY m.model_name, r.dataset_name
ORDER BY mean_accuracy DESC;