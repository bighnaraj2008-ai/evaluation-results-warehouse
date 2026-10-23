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