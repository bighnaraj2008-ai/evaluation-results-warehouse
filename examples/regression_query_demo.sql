-- =============================================================================
-- examples/regression_query_demo.sql
-- Performance regression detection query example
-- =============================================================================
-- Demonstrates filtering on critical and high severity regressions
SELECT
    severity,
    regression_flags,
    model_name,
    candidate_version,
    baseline_version,
    accuracy_delta,
    pass_rate_delta,
    latency_delta_ms
FROM (
    SELECT 'critical' AS severity, 'accuracy_drop' AS regression_flags, 'claude-3-5-sonnet' AS model_name, '20241022' AS candidate_version, '20240620' AS baseline_version, -0.14 AS accuracy_delta, -0.1667 AS pass_rate_delta, 100 AS latency_delta_ms
);