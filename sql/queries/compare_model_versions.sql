-- =============================================================================
-- compare_model_versions.sql
-- Base CTE structure for model version comparison
-- =============================================================================
WITH params AS (
    SELECT
        'rag_qa'     AS dataset_name,
        'gpt-4o'     AS baseline_model_name,
        '2024-08-06' AS baseline_model_version
),
baseline_run AS (
    SELECT
        r.run_id,
        r.dataset_name,
        r.prompt_version AS baseline_prompt_version
    FROM eval_runs r
    JOIN models m
        ON m.model_id = r.model_id
    CROSS JOIN params p
    WHERE r.status = 'completed'
      AND r.dataset_name = p.dataset_name
      AND m.model_name = p.baseline_model_name
      AND m.version = p.baseline_model_version
    ORDER BY r.executed_at DESC, r.run_id DESC
    LIMIT 1
),
shared_cases AS (
    SELECT
        br.run_id        AS baseline_run_id,
        cand.run_id      AS candidate_run_id,
        base.test_case_id
    FROM baseline_run br
    JOIN eval_results base
        ON base.run_id = br.run_id
    JOIN eval_results cand
        ON cand.test_case_id = base.test_case_id
       AND cand.run_id <> br.run_id
    JOIN eval_runs cand_run
        ON cand_run.run_id = cand.run_id
       AND cand_run.status = 'completed'
    CROSS JOIN params p
    WHERE cand_run.dataset_name = p.dataset_name
)
SELECT * FROM shared_cases;