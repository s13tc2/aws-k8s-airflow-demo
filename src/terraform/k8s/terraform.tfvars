application_name         = "airflow-app"
environment_name         = "dev"
k8s_namespace            = "app"
k8s_service_account_name = "airflow-portal"
web_airflow_image = {
  name    = "ecr-airflow-portal-dev-airflow"
  version = "2024.10.8"
}
secret_provider_class_name = "airflow-portal-dev-secret-provider-class"
airflow_fernet_key = "Q7c8Hy_FAiUKTwIxN7yWgr8ZL0uogBTitrMtLLpCFsY="