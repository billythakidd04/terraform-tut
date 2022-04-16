resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "public_dev" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "10.0.0.0/20"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "dev"
  }
}

resource "aws_route_table" "rt-dev" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "dev-public-route-table"
  }
}

resource "aws_route" "dev-route" {
  route_table_id         = aws_route_table.rt-dev.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_dev.id
  route_table_id = aws_route_table.rt-dev.id
}

resource "aws_security_group" "dev-sg" {
  name        = "dev-sg"
  description = "Security group for remote dev env on vscode"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["69.204.125.182/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-sg"
  }
}