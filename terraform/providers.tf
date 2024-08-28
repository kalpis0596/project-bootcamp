terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.52.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.40.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-southeast-1"
  /*access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"*/
}

provider "cloudflare" {
  # Configuration options
  api_token = var.CLOUDFLARE_API_TOKEN
}
