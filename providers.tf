provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region_master
  alias   = "region_master"
}
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region_worker
  alias   = "region_worker"
}
