-- =============================================================================
-- assert_positive_scores.sql
-- Verify all scored evaluation metrics are non-negative
-- =============================================================================
SELECT COUNT(*) AS violation_count
FROM eval_results
WHERE score_accuracy < 0.0
   OR score_faithfulness < 0.0
   OR score_latency_ms < 0;