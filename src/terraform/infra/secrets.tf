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