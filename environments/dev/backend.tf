terraform {
  backend "s3" {
    # Replace with the bucket name output from `make bootstrap`
    bucket         = "REPLACE_WITH_YOUR_STATE_BUCKET"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
