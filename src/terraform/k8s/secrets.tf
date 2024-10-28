# ./src/terraform/k8s/secrets.tf

# Generate Fernet key
resource "random_password" "fernet_key" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create Fernet key secret
resource "kubernetes_secret" "airflow_fernet_key" {
  metadata {
    name      = "airflow-${var.environment_name}-fernet-key"  # Dynamic name based on environment
    namespace = var.k8s_namespace
  }

  data = {
    "airflow-fernet-key" = base64encode(random_password.fernet_key.result)
  }
}

# Create connection string secret
resource "kubernetes_secret" "airflow_connection" {
  metadata {
    name      = var.airflow_connection_string_secret  # Use the variable for the secret name
    namespace = var.k8s_namespace
  }

  data = {
    "airflow-connection-string" = var.airflow_connection_string
  }
}