-- =============================================================================
-- examples/leaderboard_report.sql
-- Model leaderboard summary reporting SQL script
-- =============================================================================
SELECT
    dataset_name,
    category,
    rank_in_scope,
    model_name,
    model_version,
    avg_accuracy,
    pass_rate,
    composite_score
FROM v_eval_summary_leaderboard
WHERE category = 'ALL'
ORDER BY dataset_name, rank_in_scope;