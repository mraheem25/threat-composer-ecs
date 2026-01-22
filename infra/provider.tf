terraform {

  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.25"
    }
  }

backend "s3" {
    bucket         = "threatcomposer-s3"
    key            = "threatcomposer/terraform.tfstate"
    region         = "eu-west-2"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-2"
}