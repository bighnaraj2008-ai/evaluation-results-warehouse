-- =============================================================================
-- sql/seeds/006_prompt_templates_seed.sql
-- Prompt template version seed records
-- =============================================================================

INSERT OR IGNORE INTO prompt_templates (template_id, name, version, template_text, created_at) VALUES
    (1, 'rag_answer', 'v1.0', 'Answer the question using only the retrieved context. Cite the supporting passage.', '2024-06-01T00:00:00Z'),
    (2, 'rag_answer', 'v2.0', 'Answer using only retrieved context. Cite every factual claim and refuse when evidence is missing.', '2024-10-15T00:00:00Z'),
    (3, 'mmlu_cot', 'v1.0', 'Think step by step, then output the final answer on a single line.', '2024-06-01T00:00:00Z'),
    (4, 'summarize_brief', 'v1.0', 'Summarize in at most 120 words. Preserve named entities and numeric facts.', '2024-06-01T00:00:00Z'),
    (5, 'summarize_brief', 'v2.0', 'Summarize in at most 80 words. Preserve SLA figures, dates, and named entities.', '2024-10-15T00:00:00Z');