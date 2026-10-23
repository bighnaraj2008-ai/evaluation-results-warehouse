# Troubleshooting Guide

### Common Pitfalls
1. **Unmatched Test Suites**: Comparing runs that did not evaluate identical test cases leads to misleading metrics. Always use inner join on 	est_case_id.
2. **Floating Point Ties**: Always compare scores using integer basis points (ROUND(score * 10000)) to avoid IEEE 754 precision issues.
3. **Foreign Key Violations**: Ensure models and prompt_templates exist prior to creating eval_runs.