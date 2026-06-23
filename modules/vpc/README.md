# VPC Module

Creates a production-ready VPC with:
- Public + private subnets across up to 3 AZs
- Internet Gateway and NAT Gateways (single or per-AZ)
- Route tables for public and private tiers
- VPC Flow Logs → CloudWatch (30-day retention)
- DNS hostnames and resolution enabled

Set `single_nat_gateway = true` in dev/staging to reduce NAT costs.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
