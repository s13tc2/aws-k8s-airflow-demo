application_name         = "airflow-app"
environment_name         = "dev"
k8s_namespace            = "app"
k8s_service_account_name = "airflow-portal"
web_airflow_image = {
  name    = "ecr-airflow-dev-airflow"
  version = "2024.10.6"
}
