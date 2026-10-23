# Automated Regression Alerting Playbook

### Incident Triage Protocol
1. **Critical Severity**: Both accuracy and faithfulness have regressed by > 0.02. Immediate release block.
2. **High Severity**: Accuracy drop > 0.02, pass rate drop > 0.05, or coverage mismatch. Engineering review required.
3. **Medium Severity**: Faithfulness drop > 0.02 or latency increase > 250 ms. Review trade-off before deployment.