# Changelog

All notable changes to the evaluation-results-warehouse project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-23

### Added
- Canonical relational schema with models, prompt_templates, 	est_cases, eval_runs, and eval_results.
- Idempotent seed datasets covering 6 LLM lineages across 3 benchmark suites.
- Paired head-to-head model comparison CTE with exact tie detection in basis points.
- Fleet-wide regression detection query with automatic severity classification.
- Hierarchical multi-benchmark leaderboard analytical view.
- Comprehensive SQL assertion tests for score validity and referential integrity.
- Automated CI workflows for GitHub Actions with containerized PostgreSQL and SQLite tests.