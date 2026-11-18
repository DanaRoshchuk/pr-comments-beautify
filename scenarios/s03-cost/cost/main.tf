# Priced resource for the Cost/mo column. Mock credentials let the plan run without AWS:
# creating an aws_instance makes no API calls at plan time. Never apply this workspace.
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  # Base branch: "base". PR branch: "pr".
  stage = "pr"
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfcd1f0c"
  instance_type = "m5.large"

  tags = {
    Name = "s41351-${local.stage}"
  }
}
