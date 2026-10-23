-- =============================================================================
-- scripts/smoke_test.sql
-- Pre-flight database smoke test query script
-- =============================================================================
SELECT
    (SELECT COUNT(*) FROM models) AS model_count,
    (SELECT COUNT(*) FROM prompt_templates) AS template_count,
    (SELECT COUNT(*) FROM test_cases) AS test_case_count,
    (SELECT COUNT(*) FROM eval_runs) AS run_count,
    (SELECT COUNT(*) FROM eval_results) AS result_count;