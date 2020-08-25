# Security Groups

# Public
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  vpc_id      = aws_vpc.main.id
  description = "Used by the ELB for public access"

  # SSH on non-standard port
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow everything outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private
resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  vpc_id      = aws_vpc.main.id
  description = "Used by internal resources"

  # Allow everything from our VPC CIDR
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow everything outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# WWW Instance
# TODO harden this
resource "aws_security_group" "www_sg" {
  name        = "www_sg"
  vpc_id      = aws_vpc.main.id
  description = "Used for access to the www instances"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.local_ip]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.local_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
