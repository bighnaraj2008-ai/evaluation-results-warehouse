-- =============================================================================
-- compare_model_versions.sql
-- Head-to-head comparison of every candidate model version against one
-- baseline, restricted to the test cases the two runs actually share.
--
-- Edit the params CTE to choose another dataset or baseline lineage.
-- Win / tie / loss is decided per test case on the composite quality score
-- (accuracy + faithfulness); latency is reported separately and never decides
-- a win. win_rate uses all shared cases as the denominator; the stricter
-- 
on_tie_win_rate excludes ties.
--
-- Presentation note: metrics are rounded to 4 decimals with integer
-- basis-point arithmetic, which behaves the same on SQLite and PostgreSQL.
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
        b.score_faithfulness AS baseline_faithfulness,
        b.score_latency_ms   AS baseline_latency_ms,
        c.score_accuracy     AS candidate_accuracy,
        c.score_faithfulness AS candidate_faithfulness,
        c.score_latency_ms   AS candidate_latency_ms,
        c.passed             AS candidate_passed,
        CAST(ROUND(b.score_accuracy * 10000) AS INTEGER)
            + CAST(ROUND(b.score_faithfulness * 10000) AS INTEGER)
            AS baseline_quality_bp,
        CAST(ROUND(c.score_accuracy * 10000) AS INTEGER)
            + CAST(ROUND(c.score_faithfulness * 10000) AS INTEGER)
            AS candidate_quality_bp
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
        AVG(candidate_faithfulness)        AS avg_faithfulness,
        AVG(candidate_latency_ms)          AS avg_latency_ms,
        AVG(baseline_accuracy)             AS baseline_accuracy,
        AVG(baseline_faithfulness)         AS baseline_faithfulness,
        AVG(baseline_latency_ms)           AS baseline_latency_ms,
        SUM(
            CASE
                WHEN candidate_quality_bp > baseline_quality_bp
                THEN 1 ELSE 0
            END
        ) AS wins,
        SUM(
            CASE
                WHEN candidate_quality_bp = baseline_quality_bp
                THEN 1 ELSE 0
            END
        ) AS ties,
        SUM(
            CASE
                WHEN candidate_quality_bp < baseline_quality_bp
                THEN 1 ELSE 0
            END
        ) AS losses,
        SUM(CASE WHEN candidate_passed THEN 1 ELSE 0 END) * 1.0
            / COUNT(*) AS pass_rate
    FROM paired
    GROUP BY candidate_run_id
),
scored AS (
    SELECT
        cm.*,
        cm.avg_accuracy - cm.baseline_accuracy             AS accuracy_delta,
        cm.avg_faithfulness - cm.baseline_faithfulness     AS faithfulness_delta,
        cm.avg_latency_ms - cm.baseline_latency_ms         AS latency_delta_ms,
        cm.wins * 1.0 / cm.shared_test_cases               AS win_rate,
        CASE
            WHEN cm.wins + cm.losses = 0 THEN NULL
            ELSE cm.wins * 1.0 / (cm.wins + cm.losses)
        END AS non_tie_win_rate
    FROM candidate_metrics cm
)
SELECT
    RANK() OVER (
        ORDER BY s.win_rate DESC,
                 s.avg_accuracy DESC,
                 s.avg_latency_ms ASC
    ) AS performance_rank,
    s.candidate_run_id AS run_id,
    m.model_name,
    m.version          AS model_version,
    m.provider,
    p.dataset_name,
    p.baseline_model_name,
    p.baseline_model_version,
    br.baseline_prompt_version,
    r.prompt_version AS candidate_prompt_version,
    br.run_id        AS baseline_run_id,
    s.shared_test_cases,
    s.wins,
    s.ties,
    s.losses,
    CAST(ROUND(s.win_rate * 10000) AS INTEGER) / 10000.0          AS win_rate,
    CAST(ROUND(s.non_tie_win_rate * 10000) AS INTEGER) / 10000.0  AS non_tie_win_rate,
    CAST(ROUND(s.avg_accuracy * 10000) AS INTEGER) / 10000.0      AS avg_accuracy,
    CAST(ROUND(s.avg_faithfulness * 10000) AS INTEGER) / 10000.0  AS avg_faithfulness,
    CAST(ROUND(s.avg_latency_ms * 10) AS INTEGER) / 10.0          AS avg_latency_ms,
    CAST(ROUND(s.accuracy_delta * 10000) AS INTEGER) / 10000.0    AS accuracy_delta,
    CAST(ROUND(s.faithfulness_delta * 10000) AS INTEGER) / 10000.0 AS faithfulness_delta,
    CAST(ROUND(s.latency_delta_ms) AS INTEGER)                    AS latency_delta_ms,
    CAST(ROUND(s.pass_rate * 10000) AS INTEGER) / 10000.0         AS pass_rate,
    CAST(ROUND(s.baseline_accuracy * 10000) AS INTEGER) / 10000.0 AS baseline_accuracy,
    CAST(ROUND(s.baseline_faithfulness * 10000) AS INTEGER) / 10000.0 AS baseline_faithfulness
FROM scored s
JOIN eval_runs r
    ON r.run_id = s.candidate_run_id
JOIN models m
    ON m.model_id = r.model_id
CROSS JOIN params p
CROSS JOIN baseline_run br
ORDER BY performance_rank, m.model_name, m.version;