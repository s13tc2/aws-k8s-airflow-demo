# Security group for Airflow-related VPC endpoints
resource "aws_security_group" "airflow_vpc_endpoints" {
  name        = "airflow-vpc-endpoints-sg"
  description = "Security group for Airflow VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = values(local.private_subnets)[*].cidr_block
  }
}

# VPC Endpoints needed for Airflow
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [for rt in aws_route_table.backend : rt.id]
}

# Security group for Airflow instances
resource "aws_security_group" "airflow" {
  name        = "airflow-sg"
  description = "Security group for Airflow instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8080  # Airflow webserver
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = values(local.private_subnets)[*].cidr_block
  }

  ingress {
    from_port       = 5432  # For PostgreSQL if you're using RDS
    to_port         = 5432
    protocol        = "tcp"
    self            = true
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
