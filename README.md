# Terraform — AWS VPC + EC2 (ASG + ALB)

Production-grade Terraform project for AWS. Manages a multi-AZ VPC, an Auto Scaling Group behind an Application Load Balancer, IAM roles, and security groups — across isolated dev, staging, and prod environments.

## Architecture

```
Internet
   │
   ▼
Application Load Balancer (public subnets, 3 AZs)
   │
   ▼
Auto Scaling Group (private subnets, 3 AZs)
   │
   ├── Launch Template (Amazon Linux 2023, gp3 encrypted, IMDSv2)
   ├── IAM Role (SSM Session Manager + CloudWatch Agent)
   └── Security Group (inbound only from ALB)
```

**VPC layout per environment**

| Subnet tier | Count | Purpose |
|---|---|---|
| Public | 3 (one per AZ) | ALB, NAT Gateways |
| Private | 3 (one per AZ) | EC2 instances (ASG) |

## Repository layout

```
.
├── environments/
│   ├── dev/            # t3.micro, 1 NAT GW, ASG 1–3
│   ├── staging/        # t3.small, 1 NAT GW, ASG 1–4
│   └── prod/           # t3.medium, 3 NAT GWs, ASG 2–6, ALB deletion protection
├── modules/
│   ├── bootstrap/      # S3 state bucket + DynamoDB lock table (run once)
│   ├── vpc/            # VPC, subnets, IGW, NAT GWs, route tables, flow logs
│   ├── security_groups/# ALB SG + EC2 SG
│   ├── iam/            # EC2 instance role and profile
│   └── ec2_asg/        # Launch Template, ASG, ALB, Target Group, Listeners
├── Makefile
├── .tflint.hcl
├── .pre-commit-config.yaml
├── .terraform-version  # pins 1.9.8
└── .gitignore
```

## Prerequisites

| Tool | Install |
|---|---|
| Terraform 1.9.x | [tfenv](https://github.com/tfutils/tfenv) — `tfenv install` |
| AWS CLI | `brew install awscli` |
| tflint | `brew install tflint` |
| checkov | `pip install checkov` |
| terraform-docs | `brew install terraform-docs` |
| pre-commit | `brew install pre-commit` |

Configure AWS credentials before running any Terraform commands:

```bash
aws configure          # or export AWS_PROFILE=your-profile
```

## First-time setup

### 1. Create the remote state backend

```bash
cp modules/bootstrap/terraform.tfvars.example modules/bootstrap/terraform.tfvars
# Edit terraform.tfvars — set a globally unique bucket_name
make bootstrap
```

### 2. Wire up the backend

Paste the S3 bucket name output from step 1 into each environment's `backend.tf`:

```hcl
# environments/dev/backend.tf
terraform {
  backend "s3" {
    bucket = "your-bucket-name-here"   # ← replace
    ...
  }
}
```

### 3. Deploy an environment

```bash
make dev-init
make dev-plan
make dev-apply
```

After apply, `alb_dns_name` is printed — open it in a browser to verify the deployment.

## Daily workflow

```bash
make dev-plan       # preview changes
make dev-apply      # apply changes
make dev-destroy    # tear down (saves cost)
```

Same pattern for `staging-*` and `prod-*`.

## Code quality

```bash
make fmt            # terraform fmt -recursive
make validate       # terraform validate (all environments)
make lint           # tflint (all modules + environments)
make security       # checkov scan
make docs           # regenerate module READMEs via terraform-docs
```

### Pre-commit hooks

Install once per machine:

```bash
pre-commit install
```

Hooks run automatically on `git commit`: `terraform_fmt` → `terraform_validate` → `tflint` → `checkov` → `terraform_docs`.

## Environment differences

| Setting | dev | staging | prod |
|---|---|---|---|
| `single_nat_gateway` | `true` | `true` | `false` |
| Instance type | `t3.micro` | `t3.small` | `t3.medium` |
| ASG min / max | 1 / 3 | 1 / 4 | 2 / 6 |
| ALB deletion protection | off | off | **on** |

## Security notes

- **No bastion host** — use [AWS SSM Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html) to get a shell: `aws ssm start-session --target <instance-id>`
- EC2 instances have no public IP and are unreachable except through the ALB
- IMDSv2 is enforced on all instances (`http_tokens = "required"`)
- Root EBS volumes are encrypted (gp3)
- VPC Flow Logs ship to CloudWatch (30-day retention)
- Terraform state is encrypted at rest in S3 with versioning enabled

## Adding HTTPS

Set `certificate_arn` in the environment's `terraform.tfvars`:

```hcl
certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc-..."
```

The HTTP listener will automatically redirect to HTTPS and a TLS 1.3 listener will be created.
