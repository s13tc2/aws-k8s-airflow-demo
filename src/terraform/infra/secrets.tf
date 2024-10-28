resource "aws_secretsmanager_secret" "database_connection_string" {
  name        = "${var.application_name}-${var.environment_name}-connection-string"
  description = "Database connection string"
  recovery_window_in_days = 0  # This forces immediate deletion
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "database_connection_string" {
  secret_id     = aws_secretsmanager_secret.database_connection_string.id
  secret_string = random_password.database_connection_string.result
}

resource "random_password" "database_connection_string" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "fernet_key" {
  name = "${var.application_name}-${var.environment_name}-fernet-key"
  description = "Airflow fernet key for encryption"
  recovery_window_in_days = 0 # This forces immediate deletion
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "fernet_key" {
  secret_id = aws_secretsmanager_secret.fernet_key.id
  secret_string = random_password.fernet_key.result
}

resource "random_password" "fernet_key" {
  length = 32  # Fernet keys should be 32 bytes
  special = true
  override_special = "_-" # Limiting special characters for fernet key compatibility
  upper = true
  lower = true
  number = true
}