provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  required_version = ">= 1.4.0"
  backend "s3" {
    bucket  = "<BACKEND_BUCKET_NAME>"
    region  = "ap-northeast-1"
    key     = "logs/terraform.tfstate"
    encrypt = true
  }
}
