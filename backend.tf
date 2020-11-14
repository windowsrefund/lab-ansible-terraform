# Set S3 backend for persisting TF state file remotely, ensure bucket already exists
# and that AWS user being used by TF has read/write perms
terraform {
  required_version = ">=0.13.5"
  required_providers {
    aws = ">=3.0.0"
  }
  backend "s3" {
    region  = "us-east-1"
    profile = "adamkosmin-terraform"
    key     = "terraformstatefile"
    bucket  = "adamkosmin-tf-state"
  }
}
