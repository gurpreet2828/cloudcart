terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Get the provider from HashiCorp's registry
      version = "~> 6.0"        # Use version 6.0 or any newer version within 6.x (not 7.x)
    }
  }
  required_version = ">= 1.0" # Require Terraform CLI version 1.0 or newer to run this configuration
}
provider "aws" {
  region = var.aws_region # Use the AWS region from a variable

}

data "aws_caller_identity" "current" {}
  # This data source retrieves the AWS account ID of the current user