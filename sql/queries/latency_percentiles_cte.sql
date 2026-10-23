-- =============================================================================
-- latency_percentiles_cte.sql
-- Portable nearest-rank window CTE calculating P50, P95, and P99 latencies
-- =============================================================================
WITH ordered_latencies AS (
    SELECT
        run_id,
        score_latency_ms,
        ROW_NUMBER() OVER (PARTITION BY run_id ORDER BY score_latency_ms) AS rank_val,
        COUNT(*) OVER (PARTITION BY run_id) AS total_count
    FROM eval_results
)
SELECT
    run_id,
    MAX(CASE WHEN rank_val <= CAST(total_count * 0.50 AS INTEGER) THEN score_latency_ms END) AS p50_latency_ms,
    MAX(CASE WHEN rank_val <= CAST(total_count * 0.95 AS INTEGER) THEN score_latency_ms END) AS p95_latency_ms,
    MAX(CASE WHEN rank_val <= CAST(total_count * 0.99 AS INTEGER) THEN score_latency_ms END) AS p99_latency_ms
FROM ordered_latencies
GROUP BY run_id
ORDER BY run_id;