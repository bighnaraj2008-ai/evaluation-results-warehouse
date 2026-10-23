-- =============================================================================
-- evaluation-results-warehouse
-- 001_eval_warehouse.sql - canonical relational schema
-- =============================================================================

BEGIN;

DROP TABLE IF EXISTS eval_results;
DROP TABLE IF EXISTS eval_runs;
DROP TABLE IF EXISTS models;

-- -----------------------------------------------------------------------------
-- models: one row per (model_name, version, provider) lineage node.
-- -----------------------------------------------------------------------------
CREATE TABLE models (
    model_id    INTEGER     PRIMARY KEY,
    model_name  TEXT        NOT NULL,
    version     TEXT        NOT NULL,
    provider    TEXT        NOT NULL,
    created_at  TEXT        NOT NULL,
    CONSTRAINT uq_models_lineage UNIQUE (model_name, version, provider)
);

-- -----------------------------------------------------------------------------
-- eval_runs: one evaluation execution of a model version over a dataset.
-- -----------------------------------------------------------------------------
CREATE TABLE eval_runs (
    run_id             INTEGER  PRIMARY KEY,
    model_id           INTEGER  NOT NULL,
    dataset_name       TEXT     NOT NULL,
    prompt_version     TEXT     NOT NULL,
    prompt_template_id INTEGER,
    executed_at        TEXT     NOT NULL,
    status             TEXT     NOT NULL DEFAULT 'pending',
    CONSTRAINT fk_eval_runs_model
        FOREIGN KEY (model_id) REFERENCES models (model_id) ON DELETE RESTRICT,
    CONSTRAINT ck_eval_runs_status
        CHECK (status IN ('pending', 'running', 'completed', 'failed'))
);

-- -----------------------------------------------------------------------------
-- eval_results: one scored test case inside a run. Scores are normalised to
-- [0, 1]; latency is recorded in milliseconds. (run_id, test_case_id) is unique
-- so a case cannot be double-counted within a run.
-- -----------------------------------------------------------------------------
CREATE TABLE eval_results (
    result_id          INTEGER  PRIMARY KEY,
    run_id             INTEGER  NOT NULL,
    test_case_id       TEXT     NOT NULL,
    score_accuracy     REAL     NOT NULL,
    score_faithfulness REAL     NOT NULL,
    score_latency_ms   INTEGER  NOT NULL,
    passed             BOOLEAN  NOT NULL,
    error_details      TEXT,
    CONSTRAINT fk_eval_results_run
        FOREIGN KEY (run_id) REFERENCES eval_runs (run_id) ON DELETE CASCADE,
    CONSTRAINT uq_eval_results_run_case UNIQUE (run_id, test_case_id),
    CONSTRAINT ck_eval_results_accuracy
        CHECK (score_accuracy >= 0.0 AND score_accuracy <= 1.0),
    CONSTRAINT ck_eval_results_faithfulness
        CHECK (score_faithfulness >= 0.0 AND score_faithfulness <= 1.0),
    CONSTRAINT ck_eval_results_latency
        CHECK (score_latency_ms >= 0)
);

COMMIT;