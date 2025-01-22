#setting remote s3 as backend
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    profile        = "iam2025"
    bucket         = "healthcarenorth-s3backendforterraform"
    region         = "eu-west-2"
    key            = "terraform/tfstate"
    dynamodb_table = "terraform_locks"
  }
}