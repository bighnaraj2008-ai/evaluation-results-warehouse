-- =============================================================================
-- regression_detector.sql
-- Base CTE structure for regression detection
-- =============================================================================
WITH params AS (
    SELECT
        0.02  AS accuracy_drop_threshold,
        0.02  AS faithfulness_drop_threshold,
        0.05  AS pass_rate_drop_threshold,
        250   AS latency_increase_threshold_ms
),
run_base AS (
    SELECT
        r.run_id,
        r.model_id,
        m.model_name,
        m.version,
        m.provider,
        m.created_at,
        r.dataset_name,
        r.prompt_version,
        r.executed_at,
        COUNT(e.result_id) AS total_cases
    FROM eval_runs r
    JOIN models m
        ON m.model_id = r.model_id
    JOIN eval_results e
        ON e.run_id = r.run_id
    WHERE r.status = 'completed'
    GROUP BY
        r.run_id, r.model_id, m.model_name, m.version, m.provider,
        m.created_at, r.dataset_name, r.prompt_version, r.executed_at
),
version_pairs AS (
    SELECT
        rb.*,
        LAG(rb.run_id) OVER (
            PARTITION BY rb.model_name, rb.dataset_name
            ORDER BY rb.created_at, rb.executed_at, rb.run_id
        ) AS baseline_run_id,
        LAG(rb.version) OVER (
            PARTITION BY rb.model_name, rb.dataset_name
            ORDER BY rb.created_at, rb.executed_at, rb.run_id
        ) AS baseline_version,
        LAG(rb.prompt_version) OVER (
            PARTITION BY rb.model_name, rb.dataset_name
            ORDER BY rb.created_at, rb.executed_at, rb.run_id
        ) AS baseline_prompt_version,
        LAG(rb.executed_at) OVER (
            PARTITION BY rb.model_name, rb.dataset_name
            ORDER BY rb.created_at, rb.executed_at, rb.run_id
        ) AS baseline_executed_at,
        LAG(rb.total_cases) OVER (
            PARTITION BY rb.model_name, rb.dataset_name
            ORDER BY rb.created_at, rb.executed_at, rb.run_id
        ) AS baseline_total_cases
    FROM run_base rb
)
SELECT * FROM version_pairs;