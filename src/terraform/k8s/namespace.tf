# resource "kubernetes_namespace" "main" {
#   metadata {
#     name = var.k8s_namespace
#     labels = {
#       name = var.k8s_namespace
#     }
#   }
# }

# Create namespace for Airflow
resource "kubernetes_namespace" "airflow" {
  metadata {
    name = var.k8s_namespace
    labels = {
      name = var.k8s_namespace
    }
  }
}
