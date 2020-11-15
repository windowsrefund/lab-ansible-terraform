variable "aws_profile" {
  type    = string
  default = "adamkosmin-terraform"
}
variable "aws_region_master" {
  type    = string
  default = "us-east-1"
}
variable "aws_region_worker" {
  type    = string
  default = "us-east-2"
}
variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}
