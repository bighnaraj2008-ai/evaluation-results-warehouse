# Evaluation Metrics Dictionary

### Core Evaluation Metrics
- **Accuracy (score_accuracy)**: Correctness of the model's generated answer against the ground truth reference. Range: [0.0, 1.0].
- **Faithfulness (score_faithfulness)**: Degree of factual consistency with provided context passage. Range: [0.0, 1.0].
- **Latency (score_latency_ms)**: Execution response time recorded in milliseconds. Range: Non-negative integers.
- **Pass Rate (pass_rate)**: Proportion of test cases in an evaluation run where passed = TRUE.
- **Win Rate (win_rate)**: Proportion of shared benchmark test cases where candidate composite score exceeds baseline.
- **Non-Tie Win Rate (
on_tie_win_rate)**: Win rate excluding tied outcomes from the denominator: wins / (wins + losses).