data "helm_template" "airflow" {
  name       = "airflow"
  repository = "https://airflow.apache.org"
  chart      = "airflow"
  version    = "1.0.0"  # Specify the version of the chart you want to use

  # You might want to specify default values here
  values = [
    yamlencode({
      # Add your Airflow configuration values here
      executor: "KubernetesExecutor"
      # Add other configuration as needed
    })
  ]
}

resource "local_file" "airflow_values" {
  content  = data.helm_template.airflow.values
  filename = "${path.module}/values.yaml"
}

resource "helm_release" "airflow" {
  name             = "airflow"
  repository       = "https://airflow.apache.org"
  chart            = "airflow"
  namespace        = "airflow"
  create_namespace = true

  values = [
    local_file.airflow_values.filename
  ]
}