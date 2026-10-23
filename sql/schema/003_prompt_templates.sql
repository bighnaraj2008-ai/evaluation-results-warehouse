-- =============================================================================
-- sql/schema/003_prompt_templates.sql
-- Versioned prompt templates schema
-- =============================================================================

CREATE TABLE IF NOT EXISTS prompt_templates (
    template_id   INTEGER  PRIMARY KEY,
    name          TEXT     NOT NULL,
    version       TEXT     NOT NULL,
    template_text TEXT     NOT NULL,
    created_at    TEXT     NOT NULL,
    CONSTRAINT uq_prompt_templates_version UNIQUE (name, version)
);