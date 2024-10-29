# Deploy Airflow using default values
resource "helm_release" "airflow" {
  name             = "airflow"
  repository       = "https://airflow.apache.org"
  chart            = "airflow"
  version          = "1.15.0"
  namespace        = "airflow"
  create_namespace = true

  # Add timeout and other helm configurations for stability
  timeout = 600
  atomic  = true
}