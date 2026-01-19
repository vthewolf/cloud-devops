provider "aws" {
region = "eu-north-1"

default_tags {
  tags = {
    Environment = "dev"
    Project     = "tetris-k8s"
    ManagedBy   = "Terraform"
  }
}
}