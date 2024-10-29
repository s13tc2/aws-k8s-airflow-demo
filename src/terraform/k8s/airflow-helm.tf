data "helm_template" "airflow" {
  name       = "airflow"
  repository = "https://airflow.apache.org"
  chart      = "airflow"
  version    = "1.15.0"

  values = [
    yamlencode({
      executor = "KubernetesExecutor"
      # Add other necessary configurations here
    })
  ]
}

resource "local_file" "airflow_values" {
  content  = join("\n", data.helm_template.airflow.values)
  filename = "${path.module}/values.yaml"
}

resource "helm_release" "airflow" {
  name             = "airflow"
  repository       = "https://airflow.apache.org"
  chart            = "airflow"
  namespace        = "airflow"
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [
    local_file.airflow_values
  ]

  timeout = 600
  atomic  = true
}