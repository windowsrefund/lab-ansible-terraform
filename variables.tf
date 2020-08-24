variable aws_region {
  default = "us-east-1"
}

variable aws_profile {}
variable route53_primary_zone {}
variable vpc_cidr {}
variable environment {}
variable www_instance_type {}
variable www_ami {}
variable public_key_path {}
variable key_name {}

data "aws_availability_zones" "available" {}

variable cidrs {
  type = map(string)
}
