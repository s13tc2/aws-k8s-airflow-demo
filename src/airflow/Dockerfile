FROM apache/airflow:2.10.2

WORKDIR ${AIRFLOW_HOME}

COPY requirements.txt .

RUN pip3 install apache-airflow-providers-amazon \
    apache-airflow-providers-cncf-kubernetes

