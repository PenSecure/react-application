terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7"
    }
  }
  backend "s3" {
    bucket         = "pensus-state"
    key            = "infrastructure/prod/terraform.tfstate"
    region         = "us-west-1"
    #encrypt        = true
    #dynamodb_table = "your-lock-table"  # Optional: for state locking
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}