terraform {
  backend "s3" {
    # Replace with the bucket name output from `make bootstrap`
    bucket         = "ismail-rz-0909-softzino-bangladesh"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
