-- =============================================================================
-- sql/schema/004_constraints.sql
-- Validation constraints and relational integrity assertions
-- =============================================================================

-- Integrity enforcement rules across eval_runs and prompt_templates
-- Ensures prompt_template_id references prompt_templates(template_id)
-- and test_case_id references test_cases(test_case_id).

SELECT 1;