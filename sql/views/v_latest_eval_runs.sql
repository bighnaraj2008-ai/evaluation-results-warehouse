-- =============================================================================
-- sql/views/v_latest_eval_runs.sql
-- Active run tracking and recent executions view
-- =============================================================================
CREATE VIEW IF NOT EXISTS v_latest_eval_runs AS
SELECT
    r.run_id,
    m.model_name,
    m.version AS model_version,
    m.provider,
    r.dataset_name,
    r.prompt_version,
    r.executed_at,
    r.status
FROM eval_runs r
JOIN models m ON m.model_id = r.model_id
ORDER BY r.executed_at DESC, r.run_id DESC;