# Bootstrap

Creates the S3 bucket and DynamoDB table used as a shared Terraform remote state backend.
Run this **once** before initialising any environment.

```bash
cd modules/bootstrap
cp terraform.tfvars.example terraform.tfvars   # edit bucket_name
terraform init
terraform apply
```

State for the bootstrap resources themselves is stored **locally** (`.terraform/`).
Commit the resulting `.terraform.lock.hcl` but keep `terraform.tfstate` out of version control.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
