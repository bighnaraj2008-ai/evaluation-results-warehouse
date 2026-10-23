# =============================================================================
# Containerized SQL Evaluation Warehouse Runner
# =============================================================================
FROM alpine:3.19 AS base

RUN apk add --no-cache sqlite bash postgresql16-client

WORKDIR /workspace

COPY sql/ /workspace/sql/
COPY scripts/ /workspace/scripts/

CMD ["/bin/bash", "/workspace/scripts/run_warehouse.sh"]