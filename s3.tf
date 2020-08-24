# VPC Endpoint for S3

resource "aws_vpc_endpoint" "private_s3_endpoint" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [
    aws_vpc.main.main_route_table_id,
    aws_route_table.public_rt.id
  ]
  policy = <<EOF
  {
    "Statement": [
      {
        "Action": "*",
        "Effect": "Allow",
        "Resource": "*",
        "Principal": "*"
      }
    ]
  }
EOF
}

# S3 code bucket

resource "random_id" "code_bucket" {
  byte_length = 2
}

resource "aws_s3_bucket" "code" {
  bucket        = "${var.environment}-${random_id.code_bucket.dec}"
  acl           = "private"
  force_destroy = true
  tags = {
    Name        = "code_bucket"
    Environment = var.environment
  }
}
