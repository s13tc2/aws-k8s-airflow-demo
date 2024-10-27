application_name         = "airflow-app"
environment_name         = "dev"
k8s_namespace            = "airflow"
k8s_service_account_name = "airflow"
web_airflow_image = {
  name    = "ecr-airflow-dev"
  version = "2024.10.27"
}
