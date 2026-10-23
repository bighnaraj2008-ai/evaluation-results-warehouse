-- =============================================================================
-- regression_detector.sql
-- Fleet-wide scan for regressions between consecutive versions of the same
-- model family on the same dataset. The comparison baseline is the previous
-- version ordered by model release date and run execution time.
--
-- Metrics are computed on the INTERSECTION of test cases in both runs, so a
-- candidate cannot look better or worse merely because the suite changed.
-- A coverage_mismatch flag makes any remaining scope difference explicit.
--
-- Thresholds live in the params CTE and are intentionally conservative:
--   accuracy        drop greater than 0.02  -> flag
--   faithfulness    drop greater than 0.02  -> flag
--   pass rate       drop greater than 0.05  -> flag
--   latency         increase above 250 ms   -> flag
--
-- Severity is a deterministic roll-up of the individual flags:
--   critical = accuracy AND faithfulness regressions
--   high     = accuracy, pass-rate, or coverage mismatch
--   medium   = faithfulness or latency regression
--   none     = no flag tripped
--
-- Deltas are candidate minus baseline, so negative quality deltas are bad and
-- a positive latency delta means the candidate is slower.
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
),
paired_metrics AS (
    SELECT
        vp.run_id          AS candidate_run_id,
        vp.baseline_run_id,
        COUNT(c.result_id) AS shared_test_cases,
        AVG(c.score_accuracy)     AS avg_accuracy,
        AVG(c.score_faithfulness) AS avg_faithfulness,
        AVG(c.score_latency_ms)   AS avg_latency_ms,
        CASE
            WHEN COUNT(c.result_id) = 0 THEN NULL
            ELSE SUM(CASE WHEN c.passed THEN 1 ELSE 0 END) * 1.0
                 / COUNT(c.result_id)
        END AS pass_rate,
        AVG(CASE WHEN c.result_id IS NOT NULL THEN b.score_accuracy END)
            AS baseline_accuracy,
        AVG(CASE WHEN c.result_id IS NOT NULL THEN b.score_faithfulness END)
            AS baseline_faithfulness,
        AVG(CASE WHEN c.result_id IS NOT NULL THEN b.score_latency_ms END)
            AS baseline_latency_ms,
        CASE
            WHEN COUNT(c.result_id) = 0 THEN NULL
            ELSE SUM(CASE WHEN c.result_id IS NOT NULL AND b.passed THEN 1 ELSE 0 END)
                 * 1.0 / COUNT(c.result_id)
        END AS baseline_pass_rate
    FROM version_pairs vp
    LEFT JOIN eval_results b
        ON b.run_id = vp.baseline_run_id
    LEFT JOIN eval_results c
        ON c.run_id = vp.run_id
       AND c.test_case_id = b.test_case_id
    WHERE vp.baseline_run_id IS NOT NULL
    GROUP BY vp.run_id, vp.baseline_run_id
),
enriched AS (
    SELECT
        pm.*,
        vp.model_name,
        vp.version             AS candidate_version,
        vp.prompt_version      AS candidate_prompt_version,
        vp.provider,
        vp.dataset_name,
        vp.baseline_version,
        vp.baseline_prompt_version,
        vp.baseline_executed_at,
        vp.executed_at         AS candidate_executed_at,
        vp.baseline_total_cases,
        vp.total_cases         AS candidate_total_cases
    FROM paired_metrics pm
    JOIN version_pairs vp
        ON vp.run_id = pm.candidate_run_id
),
deltas AS (
    SELECT
        e.*,
        e.avg_accuracy - e.baseline_accuracy             AS accuracy_delta,
        e.avg_faithfulness - e.baseline_faithfulness     AS faithfulness_delta,
        e.avg_latency_ms - e.baseline_latency_ms         AS latency_delta_ms,
        e.pass_rate - e.baseline_pass_rate               AS pass_rate_delta
    FROM enriched e
),
thresholded AS (
    SELECT
        d.*,
        CASE
            WHEN d.accuracy_delta < -p.accuracy_drop_threshold THEN 1
            ELSE 0
        END AS accuracy_regression,
        CASE
            WHEN d.faithfulness_delta < -p.faithfulness_drop_threshold THEN 1
            ELSE 0
        END AS faithfulness_regression,
        CASE
            WHEN d.pass_rate_delta < -p.pass_rate_drop_threshold THEN 1
            ELSE 0
        END AS pass_rate_regression,
        CASE
            WHEN d.latency_delta_ms > p.latency_increase_threshold_ms THEN 1
            ELSE 0
        END AS latency_regression,
        CASE
            WHEN d.shared_test_cases <> d.candidate_total_cases
              OR d.shared_test_cases <> d.baseline_total_cases THEN 1
            ELSE 0
        END AS coverage_mismatch
    FROM deltas d
    CROSS JOIN params p
),
labeled AS (
    SELECT
        t.*,
        CASE
            WHEN t.accuracy_regression = 1
             AND t.faithfulness_regression = 1 THEN 'critical'
            WHEN t.accuracy_regression = 1
              OR t.pass_rate_regression = 1
              OR t.coverage_mismatch = 1 THEN 'high'
            WHEN t.faithfulness_regression = 1
              OR t.latency_regression = 1 THEN 'medium'
            ELSE 'none'
        END AS severity,
        TRIM(
            CASE WHEN t.accuracy_regression = 1 THEN 'accuracy_drop ' ELSE '' END ||
            CASE WHEN t.faithfulness_regression = 1 THEN 'faithfulness_drop ' ELSE '' END ||
            CASE WHEN t.pass_rate_regression = 1 THEN 'pass_rate_drop ' ELSE '' END ||
            CASE WHEN t.latency_regression = 1 THEN 'latency_increase ' ELSE '' END ||
            CASE WHEN t.coverage_mismatch = 1 THEN 'coverage_mismatch ' ELSE '' END
        ) AS flag_text
    FROM thresholded t
)
SELECT
    l.severity,
    CASE WHEN l.flag_text = '' THEN 'none' ELSE l.flag_text END AS regression_flags,
    l.model_name,
    l.baseline_version,
    l.baseline_prompt_version,
    l.candidate_version,
    l.candidate_prompt_version,
    l.provider,
    l.dataset_name,
    l.baseline_run_id,
    l.candidate_run_id,
    l.baseline_executed_at,
    l.candidate_executed_at,
    l.baseline_total_cases,
    l.candidate_total_cases,
    l.shared_test_cases,
    CAST(ROUND(l.baseline_accuracy * 10000) AS INTEGER) / 10000.0     AS baseline_accuracy,
    CAST(ROUND(l.avg_accuracy * 10000) AS INTEGER) / 10000.0          AS candidate_accuracy,
    CAST(ROUND(l.accuracy_delta * 10000) AS INTEGER) / 10000.0        AS accuracy_delta,
    CAST(ROUND(l.baseline_faithfulness * 10000) AS INTEGER) / 10000.0 AS baseline_faithfulness,
    CAST(ROUND(l.avg_faithfulness * 10000) AS INTEGER) / 10000.0      AS candidate_faithfulness,
    CAST(ROUND(l.faithfulness_delta * 10000) AS INTEGER) / 10000.0    AS faithfulness_delta,
    CAST(ROUND(l.baseline_pass_rate * 10000) AS INTEGER) / 10000.0    AS baseline_pass_rate,
    CAST(ROUND(l.pass_rate * 10000) AS INTEGER) / 10000.0             AS candidate_pass_rate,
    CAST(ROUND(l.pass_rate_delta * 10000) AS INTEGER) / 10000.0       AS pass_rate_delta,
    CAST(ROUND(l.baseline_latency_ms) AS INTEGER)                     AS baseline_latency_ms,
    CAST(ROUND(l.avg_latency_ms) AS INTEGER)                          AS candidate_latency_ms,
    CAST(ROUND(l.latency_delta_ms) AS INTEGER)                        AS latency_delta_ms,
    l.accuracy_regression,
    l.faithfulness_regression,
    l.pass_rate_regression,
    l.latency_regression,
    l.coverage_mismatch
FROM labeled l
ORDER BY
    CASE l.severity
        WHEN 'critical' THEN 0
        WHEN 'high' THEN 1
        WHEN 'medium' THEN 2
        ELSE 3
    END,
    l.model_name,
    l.dataset_name;