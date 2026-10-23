# Evaluation Warehouse Guide

How to interpret this warehouse, trust its comparisons, and write new
comparative CTE queries without fooling yourself.

---

## 1. Grain and mental model

| Table | Grain | One row means |
|---|---|---|
| models | model lineage | A provider snapshot such as GPT-4o 2024-11-20 |
| eval_runs | run | One model version executed on one dataset with one prompt |
| eval_results | result | One test case scored inside one run |
| 	est_cases | case | A golden question, category, and expected answer |

Every aggregate in this repository can be rebuilt from eval_results by joining
up to eval_runs, models, and 	est_cases. If a number cannot be traced back
to those rows, it does not belong in a release decision.

**Canonical filter:** every comparison, regression, and leaderboard metric uses
eval_runs.status = 'completed'. Pending, running, and failed runs are
operational state, not evidence. _run_metrics is the deliberate exception: it
reports every run so zero-result and failed executions remain auditable.
---

## 2. Metric definitions

### Quality metrics
- score_accuracy: Task correctness for one case (0-1).
- score_faithfulness: Grounding in the provided context (0-1).
- pass_rate: Ratio of passed test cases to total cases.

### Comparison metrics
For candidate vs baseline on shared test cases:
- win: candidate score > baseline score
- tie: candidate score == baseline score
- loss: candidate score < baseline score
- win_rate: wins / shared_cases
- non_tie_win_rate: wins / (wins + losses)