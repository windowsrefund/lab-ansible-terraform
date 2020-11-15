# SG for Jenkins ALB
resource "aws_security_group" "jenkins_lb_sg" {
  provider    = aws.region_master
  name        = "jenkins-lb-sg"
  description = "Manage traffic for Jenkins SG"
  vpc_id      = aws_vpc.vpc_master.id
  ingress {
    description = "Allow 443 from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow 80 from anywhere for redirection"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG for Jenkins
resource "aws_security_group" "jenkins_sg" {
  provider    = aws.region_master
  name        = "jenkins-sg"
  description = "Allow TCP/8080 & TCP/22"
  vpc_id      = aws_vpc.vpc_master.id
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description     = "Allow TCP/8080 from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_lb_sg.id]
  }
  ingress {
    description = "Allow traffic from us-west-2"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.1.0/24"]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG for Jenkins in us-west-2
resource "aws_security_group" "jenkins_sg_oregon" {
  provider    = aws.region_worker
  name        = "jenkins-sg-oregon"
  description = "Allow traffic from us-east-1"
  vpc_id      = aws_vpc.vpc_master_oregon.id
  ingress {
    description = "Allow SSH from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow traffic from us-east-1"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
