provider "aws" {
region = "eu-west-1"

default_tags {
  tags = {
    Environment = "dev"
    Project     = "tetris-k8s"
    ManagedBy   = "Terraform"
  }
}
}

terraform {
required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.28.0"
    }
  }
  backend "s3" {
    bucket = "andres-victor-tetris-terraform"
    region = "eu-west-1"
    key = "terraform.tfstate"
  }  
}
