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

| Metric | Definition | Range | Reading |
|---|---|---|---|
| score_accuracy | Task correctness for one case | 0-1 | Higher is better |
| score_faithfulness | Grounding in the provided context / reference | 0-1 | Higher is better |
| passed | Evaluator verdict for one case | boolean | Pass threshold is upstream |
| pass_rate | passed_cases / total_cases | 0-1 | Higher is better |

The seed's upstream pass rule is ccuracy >= 0.70 AND faithfulness >= 0.65.
The warehouse stores the verdict; it does not re-derive it.

### Latency metrics

| Metric | Definition | Use |
|---|---|---|
| vg_latency_ms | Mean case latency | Trend, not an SLO |
| median_latency_ms | Middle value | Robust typical latency |
| p95_latency_ms | Nearest-rank 95th percentile | Tail behaviour |
| min / max | Extremes | Outlier investigation |

---

## 3. Reading the comparison query

sql/queries/compare_model_versions.sql answers: *on the cases both versions
ran, how often did the candidate beat the baseline?*

Key columns:
- performance_rank: Rank by win rate, then accuracy, then latency
- shared_test_cases: Size of the paired suite
- wins / 	ies / losses: Per-case outcomes
- win_rate: Wins including ties in the denominator
- 
on_tie_win_rate: Wins among decisive cases

---

## 4. Reading the regression detector

sql/queries/regression_detector.sql compares consecutive versions of the same
model family on the same dataset. It computes all metrics on the intersection of
test cases present in both runs.

Thresholds:
- Accuracy: drop > 0.02
- Faithfulness: drop > 0.02
- Pass rate: drop > 0.05
- Latency: increase > 250 ms

Severity levels:
- critical: Accuracy and faithfulness both regress
- high: Accuracy, pass rate, or coverage mismatch
- medium: Faithfulness or latency regresses
- 
one: No threshold tripped