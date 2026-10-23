# Dimensional Architecture & Data Flow

`	ext
                       +-----------------------+
                       |        models         |
                       |  lineage + provider   |
                       +-----------+-----------+
                                   |
                                   | 1:N
                       +-----------v-----------+        +-----------------------+
                       |       eval_runs       +------->|   prompt_templates    |
                       | dataset / prompt / ts |        | versioned instructions|
                       +-----------+-----------+        +-----------------------+
                                   |
                                   | 1:N
                       +-----------v-----------+
                       |     eval_results      |<-------+
                       | scores + pass + error |        |
                       +-----------------------+        |
                                                        |
                       +-----------------------+        |
                       |      test_cases       +--------+
                       | dataset / category    |
                       +-----------------------+
`

The fact table is eval_results; eval_runs is its run-level dimension;
models, 	est_cases, and prompt_templates are conformed dimensions.