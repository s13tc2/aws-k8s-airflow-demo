data "helm_template" "airflow" {
  name       = "airflow"
  repository = "https://airflow.apache.org"
  chart      = "airflow"
  version    = "1.15.0"  # Specify the version of the chart you want to use
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