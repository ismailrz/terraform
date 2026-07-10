terraform {
  backend "s3" {
    bucket         = "my-company-terraform-state-abc123"
    key            = "prod/terraform.tfstate"
    profile        = "ismail-devops-original-id"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
