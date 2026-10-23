-- =============================================================================
-- compare_model_versions.sql
-- Head-to-head comparison of candidate model versions against a baseline
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
),
paired AS (
    SELECT
        sc.baseline_run_id,
        sc.candidate_run_id,
        sc.test_case_id,
        b.score_accuracy     AS baseline_accuracy,
        c.score_accuracy     AS candidate_accuracy,
        c.passed             AS candidate_passed,
        CAST(ROUND(b.score_accuracy * 10000) AS INTEGER) AS baseline_quality_bp,
        CAST(ROUND(c.score_accuracy * 10000) AS INTEGER) AS candidate_quality_bp
    FROM shared_cases sc
    JOIN eval_results b
        ON b.run_id = sc.baseline_run_id
       AND b.test_case_id = sc.test_case_id
    JOIN eval_results c
        ON c.run_id = sc.candidate_run_id
       AND c.test_case_id = sc.test_case_id
),
candidate_metrics AS (
    SELECT
        candidate_run_id,
        COUNT(*)                           AS shared_test_cases,
        AVG(candidate_accuracy)            AS avg_accuracy,
        AVG(baseline_accuracy)             AS baseline_accuracy,
        SUM(CASE WHEN candidate_quality_bp > baseline_quality_bp THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN candidate_quality_bp = baseline_quality_bp THEN 1 ELSE 0 END) AS ties,
        SUM(CASE WHEN candidate_quality_bp < baseline_quality_bp THEN 1 ELSE 0 END) AS losses,
        SUM(CASE WHEN candidate_passed THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS pass_rate
    FROM paired
    GROUP BY candidate_run_id
)
SELECT
    candidate_run_id,
    shared_test_cases,
    wins,
    ties,
    losses,
    wins * 1.0 / shared_test_cases AS win_rate,
    avg_accuracy - baseline_accuracy AS accuracy_delta
FROM candidate_metrics;