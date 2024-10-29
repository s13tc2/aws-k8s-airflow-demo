# network-public.tf (renamed from network-frontend.tf)

resource "aws_subnet" "frontend" {           # renamed from "frontend"
  for_each = local.public_subnets
  vpc_id = aws_vpc.main.id
  availability_zone = each.value.availability_zone
  cidr_block = each.value.cidr_block
  map_public_ip_on_launch = true
}

# Route table for public subnets (internet access via IGW)
resource "aws_route_table" "frontend" {      # renamed from "frontend"
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  depends_on = [
    aws_vpc.main,
    aws_internet_gateway.main
  ]
}

resource "aws_route_table_association" "frontend" {    # renamed from "frontend"
  for_each = aws_subnet.frontend
  subnet_id = each.value.id
  route_table_id = aws_route_table.frontend.id
}