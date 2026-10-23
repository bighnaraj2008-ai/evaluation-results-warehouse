-- =============================================================================
-- prompt_version_impact.sql
-- Isolates prompt version changes across identical model lineages
-- =============================================================================
WITH prompt_pairs AS (
    SELECT
        m.model_name,
        r.dataset_name,
        r.prompt_version,
        AVG(e.score_accuracy)     AS avg_accuracy,
        AVG(e.score_faithfulness) AS avg_faithfulness,
        AVG(e.score_latency_ms)   AS avg_latency_ms,
        COUNT(e.result_id)        AS total_results
    FROM eval_runs r
    JOIN models m ON m.model_id = r.model_id
    JOIN eval_results e ON e.run_id = r.run_id
    WHERE r.status = 'completed'
    GROUP BY m.model_name, r.dataset_name, r.prompt_version
)
SELECT
    model_name,
    dataset_name,
    prompt_version,
    total_results,
    CAST(ROUND(avg_accuracy * 10000) AS INTEGER) / 10000.0 AS avg_accuracy,
    CAST(ROUND(avg_faithfulness * 10000) AS INTEGER) / 10000.0 AS avg_faithfulness,
    CAST(ROUND(avg_latency_ms) AS INTEGER) AS avg_latency_ms
FROM prompt_pairs
ORDER BY model_name, dataset_name, prompt_version;