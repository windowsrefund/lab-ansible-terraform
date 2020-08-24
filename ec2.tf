resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)

}

resource "aws_instance" "www" {
  instance_type          = var.www_instance_type
  ami                    = var.www_ami
  key_name               = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.www_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.s3_access_profile.id
  subnet_id              = aws_subnet.public1_subnet.id

  tags = {
    Name        = "www"
    Environment = var.environment
  }

  # add provisioner

}
