-- =============================================================================
-- sql/schema/002_test_cases.sql
-- Benchmark test cases catalog schema
-- =============================================================================

CREATE TABLE IF NOT EXISTS test_cases (
    test_case_id    TEXT  PRIMARY KEY,
    dataset_name    TEXT  NOT NULL,
    category        TEXT  NOT NULL,
    question        TEXT  NOT NULL,
    expected_answer TEXT  NOT NULL,
    created_at      TEXT  NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_test_cases_dataset_category
    ON test_cases (dataset_name, category);