terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.1.0"
    }
  }
}

provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["$HOME/.aws/credentials"]
}

variable "user_id" {}
variable "db_url" {}
variable "environment" {}

module "backend" {
  source = "../modules/backend"

  user_id     = var.user_id
  db_url      = var.db_url
  environment = var.environment
}
