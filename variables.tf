variable region {
  default = "us-east-1"
}

variable profile {}
variable route53_primary_zone {}
variable vpc_cidr {}
variable environment {}

data "aws_availability_zones" "available" {}

variable cidrs {
  type = map(string)
}
