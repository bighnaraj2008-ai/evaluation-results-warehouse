-- =============================================================================
-- examples/advanced_ctes.sql
-- Advanced CTE evaluation query example
-- =============================================================================
WITH ranked_runs AS (
    SELECT
        r.run_id,
        m.model_name,
        m.version,
        AVG(e.score_accuracy) AS avg_accuracy,
        RANK() OVER (ORDER BY AVG(e.score_accuracy) DESC) AS rank_pos
    FROM eval_runs r
    JOIN models m ON m.model_id = r.model_id
    JOIN eval_results e ON e.run_id = r.run_id
    WHERE r.status = 'completed'
    GROUP BY r.run_id, m.model_name, m.version
)
SELECT * FROM ranked_runs WHERE rank_pos <= 5;