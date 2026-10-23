-- =============================================================================
-- evaluation-results-warehouse
-- 001_eval_warehouse.sql - canonical relational schema
-- =============================================================================

BEGIN;

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

COMMIT;