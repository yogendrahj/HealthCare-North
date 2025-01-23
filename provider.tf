# Specifying required providers and the terraform versions. 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" # A version constraint, that will use any version in the 4.x range. 
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "iam2025"
}