terraform {
  backend "s3" {
    # Replace with the bucket name output from `make bootstrap`
    bucket         = "my-company-terraform-state-abc123"
    key            = "dev/terraform.tfstate"
    profile        = "ismail-devops-original-id"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
