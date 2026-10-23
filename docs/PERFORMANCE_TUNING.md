# Query Performance Tuning Guide

### Indexing Strategy
- **Composite Indexes**: Composite indexes on (run_id, passed) and (dataset_name, status) enable fast filtering without full table scans.
- **Join Optimization**: All analytical queries join on indexed primary and foreign keys (	est_case_id, un_id, model_id).

### CTE Materialization
- Under SQLite and PostgreSQL 16, common table expressions are inlined or materialized automatically based on cost estimation.