# evaluation-results-warehouse

A pure-SQL warehouse for storing LLM evaluation runs and answering the questions
that actually decide a release: **Which model version is better on the same test
suite? Did the candidate regress? Which version leads each test category?**

All warehouse logic lives in SQL: relational tables, foreign keys, check
constraints, indexes, analytical views, CTEs, window functions, and joins. There
is no application code and no ORM.

---

## Status

- **Built and verified locally** with SQLite 3.49.1 (Python 3.12).
- Schema applies cleanly, seeds are idempotent, and all three analytical
  workloads return validated metrics.
- The repository is initialized with Git and adheres to strict security hygiene.
---

## Setup: PostgreSQL (Docker)

`ash
cd docker
docker compose up -d
docker compose exec postgres psql -U eval -d eval_warehouse
`

The compose file mounts the schema and seed files as PostgreSQL init scripts.

---

## Analytical CTE Queries

1. **`sql/queries/compare_model_versions.sql`**:
   Head-to-head comparison on shared test cases calculating win rates, non-tie win rates, accuracy deltas, and latency deltas.

2. **`sql/queries/regression_detector.sql`**:
   Consecutive version regression scanner with automated severity labeling (`critical`, `high`, `medium`, `none`).

3. **`sql/queries/eval_summary_leaderboard.sql`**:
   Multi-benchmark leaderboard with composite score weighting:
   `0.45 * accuracy + 0.35 * faithfulness + 0.10 * pass_rate + 0.10 * latency_score`.

---

## Example Scripts
Reference implementations and analytical templates are available in the [`examples/`](examples/) directory:
- [`sample_comparison.sql`](examples/sample_comparison.sql): Parameterized baseline vs candidate analysis.
- [`leaderboard_report.sql`](examples/leaderboard_report.sql): Executive leaderboard reporting.
- [`advanced_ctes.sql`](examples/advanced_ctes.sql): Complex analytical CTE recipes.