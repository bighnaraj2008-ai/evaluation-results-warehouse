-- =============================================================================
-- examples/custom_eval_run.sql
-- Custom evaluation run insertion example script
-- =============================================================================
BEGIN;

INSERT INTO eval_runs (run_id, model_id, dataset_name, prompt_version, prompt_template_id, executed_at, status)
VALUES (20, 2, 'rag_qa', 'v2.0', 2, '2026-10-23T12:00:00Z', 'completed');

INSERT INTO eval_results (result_id, run_id, test_case_id, score_accuracy, score_faithfulness, score_latency_ms, passed, error_details)
VALUES (133, 20, 'R01', 0.96, 0.94, 910, 1, NULL);

COMMIT;