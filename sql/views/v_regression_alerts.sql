-- =============================================================================
-- sql/views/v_regression_alerts.sql
-- Automated regression alerting view for critical and high severity events
-- =============================================================================
CREATE VIEW IF NOT EXISTS v_regression_alerts AS
SELECT
    r.run_id,
    r.dataset_name,
    m.model_name,
    m.version AS model_version,
    COUNT(CASE WHEN e.passed = 0 THEN 1 END) AS failed_case_count,
    AVG(e.score_accuracy) AS run_accuracy,
    AVG(e.score_latency_ms) AS run_latency_ms
FROM eval_runs r
JOIN models m ON m.model_id = r.model_id
JOIN eval_results e ON e.run_id = r.run_id
WHERE r.status = 'completed'
GROUP BY r.run_id, r.dataset_name, m.model_name, m.version
HAVING COUNT(CASE WHEN e.passed = 0 THEN 1 END) > 0;