-- =============================================================================
-- sql/views/v_model_leaderboard.sql
-- Executive reporting leaderboard view
-- =============================================================================
CREATE VIEW IF NOT EXISTS v_model_leaderboard AS
SELECT
    m.model_name,
    m.version AS model_version,
    m.provider,
    r.dataset_name,
    COUNT(e.result_id) AS test_case_count,
    AVG(e.score_accuracy) AS overall_accuracy,
    AVG(e.score_faithfulness) AS overall_faithfulness,
    AVG(e.score_latency_ms) AS overall_latency_ms,
    SUM(CASE WHEN e.passed THEN 1 ELSE 0 END) * 1.0 / COUNT(e.result_id) AS overall_pass_rate
FROM eval_results e
JOIN eval_runs r ON r.run_id = e.run_id
JOIN models m ON m.model_id = r.model_id
WHERE r.status = 'completed'
GROUP BY m.model_name, m.version, m.provider, r.dataset_name;