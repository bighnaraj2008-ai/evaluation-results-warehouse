-- =============================================================================
-- eval_summary_leaderboard.sql
-- Presentation layer over the persisted v_eval_summary_leaderboard view.
--
-- The view ranks every model version inside each (dataset, category) scope and
-- also exposes an "ALL" scope per dataset. The composite score is:
--   0.45 * accuracy + 0.35 * faithfulness
--   + 0.10 * pass_rate + 0.10 * latency_score
-- with latency_score decaying linearly from 1.0 at 0 ms to 0.0 at 3000 ms.
--
-- Metrics are rounded to 4 decimals (latency to 1) with portable integer
-- basis-point arithmetic. Read top-to-bottom for a category leaderboard: the
-- "ALL" rows appear first, then each category alphabetically.
-- =============================================================================
SELECT
    r.dataset_name,
    r.category,
    r.rank_in_scope,
    r.model_name,
    r.model_version,
    r.provider,
    r.run_count,
    r.case_count,
    CAST(ROUND(r.avg_accuracy * 10000) AS INTEGER) / 10000.0     AS avg_accuracy,
    CAST(ROUND(r.avg_faithfulness * 10000) AS INTEGER) / 10000.0 AS avg_faithfulness,
    CAST(ROUND(r.pass_rate * 10000) AS INTEGER) / 10000.0        AS pass_rate,
    CAST(ROUND(r.avg_latency_ms * 10) AS INTEGER) / 10.0         AS avg_latency_ms,
    CAST(ROUND(r.composite_score * 10000) AS INTEGER) / 10000.0  AS composite_score
FROM v_eval_summary_leaderboard r
ORDER BY
    r.dataset_name,
    CASE WHEN r.category = 'ALL' THEN 0 ELSE 1 END,
    r.category,
    r.rank_in_scope,
    r.model_name,
    r.model_version;