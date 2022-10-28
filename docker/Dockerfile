FROM --platform=linux/amd64 ghcr.io/dbt-labs/dbt-snowflake:1.2.0

COPY kingdotcom/ .

COPY kingdotcom/run_transformations.sh .

ENTRYPOINT ["/bin/bash", "run_transformations.sh"]

