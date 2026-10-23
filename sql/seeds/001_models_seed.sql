-- =============================================================================
-- sql/seeds/001_models_seed.sql
-- Benchmark models lineage seed dataset
-- =============================================================================

INSERT OR IGNORE INTO models (model_id, model_name, version, provider, created_at) VALUES
    (1, 'gpt-4o', '2024-08-06', 'OpenAI', '2024-08-06T00:00:00Z'),
    (2, 'gpt-4o', '2024-11-20', 'OpenAI', '2024-11-20T00:00:00Z'),
    (3, 'claude-3-5-sonnet', '20240620', 'Anthropic', '2024-06-20T00:00:00Z'),
    (4, 'claude-3-5-sonnet', '20241022', 'Anthropic', '2024-10-22T00:00:00Z'),
    (5, 'llama-3.1-70b-instruct', '2024-07-23', 'Meta', '2024-07-23T00:00:00Z'),
    (6, 'qwen-2.5-72b-instruct', '2024-09-19', 'Alibaba', '2024-09-19T00:00:00Z');