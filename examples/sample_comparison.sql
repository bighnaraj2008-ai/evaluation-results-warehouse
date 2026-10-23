-- =============================================================================
-- examples/sample_comparison.sql
-- Sample model version comparison SQL script
-- =============================================================================
-- Compares GPT-4o 2024-11-20 vs 2024-08-06 on rag_qa benchmark
SELECT
    candidate_run_id,
    shared_test_cases,
    wins,
    ties,
    losses,
    win_rate,
    accuracy_delta,
    latency_delta_ms
FROM (
    SELECT 1 AS candidate_run_id, 8 AS shared_test_cases, 6 AS wins, 2 AS ties, 0 AS losses, 0.75 AS win_rate, 0.06 AS accuracy_delta, -68 AS latency_delta_ms
);