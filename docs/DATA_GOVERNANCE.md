# Data Governance and Retention Policy

1. **Immutability**: Completed evaluation runs (status = 'completed') and their associated scored results must never be mutated.
2. **Lineage Traceability**: Every evaluation run must be strictly linked to an immutable model lineage identifier (model_name, version, provider).
3. **Retention**: All baseline run fixtures are permanently retained. Ephemeral debug runs are pruned after 90 days.