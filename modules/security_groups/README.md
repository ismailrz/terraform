# Security Groups Module

Creates two security groups:
- **ALB SG** — inbound 80/443 from `0.0.0.0/0`
- **EC2 SG** — inbound 80 from ALB SG only (no direct internet access); SSM Session Manager handles shell access without a bastion host

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
