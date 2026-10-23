# Contributing to evaluation-results-warehouse

Thank you for your interest in contributing to the evaluation results warehouse.

## Design Philosophy
1. **Pure SQL**: All relational structures, metrics, and business rules belong in pure SQL.
2. **Deterministic Comparisons**: Metrics must be paired on identical test cases.
3. **No Private Artifacts**: Never commit local SQLite databases, credentials, or private configs.

## Workflow
1. Fork the repository and create your branch from main.
2. Ensure any new query or schema DDL runs cleanly on both SQLite and PostgreSQL.
3. Add corresponding assertion tests in sql/tests/.
4. Submit a pull request with clear description and benchmark outputs.