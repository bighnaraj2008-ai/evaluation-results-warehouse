-- =============================================================================
-- sql/queries/__init__.sql
-- Analytical queries package descriptor and query registry metadata
-- =============================================================================

-- Available analytical CTE workloads:
-- 1. compare_model_versions.sql: Paired head-to-head win-rate on shared suite
-- 2. regression_detector.sql: Fleet-wide regression scanning with LAG()
-- 3. eval_summary_leaderboard.sql: Hierarchical ranking across benchmarks