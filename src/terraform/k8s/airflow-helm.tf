# Create the Helm template
data "helm_template" "airflow" {
  name       = "airflow"
  repository = "https://airflow.apache.org"
  chart      = "airflow"
  version    = "1.0.0"

  values = [
    yamlencode({
      executor = "KubernetesExecutor"
      
      # Add Kubernetes Executor configs
      kubernetes = {
        worker = {
          resources = {
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
            limits = {
              cpu    = "1000m"
              memory = "2Gi"
            }
          }
        }
      }

      # Web server configurations
      webserver = {
        resources = {
          requests = {
            cpu    = "500m"
            memory = "1Gi"
          }
          limits = {
            cpu    = "1000m"
            memory = "2Gi"
          }
        }
      }
    })
  ]
}

# Save the rendered values
resource "local_file" "airflow_values" {
  content  = data.helm_template.airflow.values[0]  # Access the first element of the values list
  filename = "${path.module}/values.yaml"
}

# Deploy Airflow
resource "helm_release" "airflow" {
  name             = "airflow"
  repository       = "https://airflow.apache.org"
  chart            = "airflow"
  namespace        = "airflow"
  create_namespace = true
  
  values = [
    data.helm_template.airflow.values[0]  # Use values directly
  ]

  # Add timeout and other helm configurations for stability
  timeout = 600
  atomic  = true
  wait    = true
}
