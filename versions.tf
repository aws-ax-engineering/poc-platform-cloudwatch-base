terraform {
  # pin major.minor versions
  required_version = "~> 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.21"
    }
    archive = {
      source = "hashicorp/archive"
      version = "~> 2.4.0"
    }

  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "aws-engineering-poc"
    workspaces {
      prefix = "poc-platform-cloudwatch-base-"
    }
  }
}


provider "aws" {
  region = var.aws_region

  # this section commented out during the initial bootstrap run.
  # once the assumeable roles are created, uncomment and change
  # op.*.env to contain the appropriate service account identity
  assume_role {
     role_arn     = "arn:aws:iam::${var.aws_account_id}:role/${var.aws_assume_role}"
     session_name = "poc-platform-cloudwatch-base"
  }

  default_tags {
    tags = {
      product  = "poc engineering platform"
      pipeline = "poc-platform-cloudwatch-base"
    }
  }
}


provider "archive" {
  
}