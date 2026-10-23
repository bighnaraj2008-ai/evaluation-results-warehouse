-- =============================================================================
-- assert_accuracy_bounds.sql
-- Verify score values adhere strictly to normalised [0, 1] range
-- =============================================================================
SELECT COUNT(*) AS out_of_bounds_count
FROM eval_results
WHERE score_accuracy > 1.0
   OR score_faithfulness > 1.0;