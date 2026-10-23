-- =============================================================================
-- sql/seeds/003_eval_runs_seed.sql
-- Execution run metadata seed records
-- =============================================================================

INSERT OR IGNORE INTO eval_runs (run_id, model_id, dataset_name, prompt_version, prompt_template_id, executed_at, status) VALUES
    (1, 1, 'rag_qa', 'v1.0', 1, '2024-08-10T09:00:00Z', 'completed'),
    (2, 1, 'mmlu_mini', 'v1.0', 3, '2024-08-11T09:00:00Z', 'completed'),
    (3, 1, 'summarization', 'v1.0', 4, '2024-08-12T09:00:00Z', 'completed'),
    (4, 2, 'rag_qa', 'v2.0', 2, '2024-11-25T09:00:00Z', 'completed'),
    (5, 2, 'mmlu_mini', 'v1.0', 3, '2024-11-26T09:00:00Z', 'completed'),
    (6, 2, 'summarization', 'v2.0', 5, '2024-11-27T09:00:00Z', 'completed'),
    (7, 3, 'rag_qa', 'v1.0', 1, '2024-07-01T09:00:00Z', 'completed'),
    (8, 3, 'mmlu_mini', 'v1.0', 3, '2024-07-02T09:00:00Z', 'completed'),
    (9, 3, 'summarization', 'v1.0', 4, '2024-07-03T09:00:00Z', 'completed'),
    (10, 4, 'rag_qa', 'v1.0', 1, '2024-11-01T09:00:00Z', 'completed'),
    (11, 4, 'mmlu_mini', 'v1.0', 3, '2024-11-02T09:00:00Z', 'completed'),
    (12, 4, 'summarization', 'v1.0', 4, '2024-11-03T09:00:00Z', 'completed'),
    (13, 5, 'rag_qa', 'v1.0', 1, '2024-08-01T09:00:00Z', 'completed'),
    (14, 5, 'mmlu_mini', 'v1.0', 3, '2024-08-02T09:00:00Z', 'completed'),
    (15, 5, 'summarization', 'v1.0', 4, '2024-08-03T09:00:00Z', 'completed'),
    (16, 6, 'rag_qa', 'v1.0', 1, '2024-10-01T09:00:00Z', 'completed'),
    (17, 6, 'mmlu_mini', 'v1.0', 3, '2024-10-02T09:00:00Z', 'completed'),
    (18, 6, 'summarization', 'v1.0', 4, '2024-10-03T09:00:00Z', 'completed');