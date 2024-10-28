output "k8s_namespace" {
  value = var.k8s_namespace
}

output "ingress_controller_namespace" {
  value = "${var.k8s_service_account_name}-ingress"
}

output "web_airflow_name" {
  value = var.web_airflow_image.name
}

output "web_airflow_version" {
  value = var.web_airflow_image.version
}

output "secret_provider_class_name" {
  value = "${var.application_name}-${var.environment_name}-secret-provider-class"
}