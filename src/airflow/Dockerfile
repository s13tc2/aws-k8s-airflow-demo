FROM apache/airflow:2.10.2

WORKDIR ${AIRFLOW_HOME}

# Install required providers
RUN pip3 install \
    apache-airflow-providers-amazon \
    apache-airflow-providers-cncf-kubernetes \
    psycopg2-binary  # Add PostgreSQL driver for SQL Alchemy connection

USER airflow

# The base image already has an entrypoint script, but you can add health check script
COPY scripts/health_check.py /opt/airflow/health_check.py

# Add health check endpoint
HEALTHCHECK CMD python3 /opt/airflow/health_check.py || exit 1

# The base Airflow image already includes these, but you can override if needed:
# ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint"]
# CMD ["webserver"]

EXPOSE 8080