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

resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "dev-public-route-table"
  }
}

resource "aws_route" "dev" {
  route_table_id         = aws_route_table.dev.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_dev.id
  route_table_id = aws_route_table.dev.id
}

resource "aws_security_group" "dev-sg" {
  name        = "dev-sg"
  description = "Security group for remote dev env on vscode"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port        = 0
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls_dev_sg"
  }
}