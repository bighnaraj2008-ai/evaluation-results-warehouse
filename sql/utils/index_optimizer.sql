-- =============================================================================
-- sql/utils/index_optimizer.sql
-- Advanced multi-column index tuning script
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_eval_results_run_perf
    ON eval_results (run_id, score_accuracy, score_latency_ms);

CREATE INDEX IF NOT EXISTS idx_eval_runs_model_dataset
    ON eval_runs (model_id, dataset_name, executed_at);