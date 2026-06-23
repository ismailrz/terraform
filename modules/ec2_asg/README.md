# EC2 ASG Module

Creates a complete compute tier:
- **Launch Template** — Amazon Linux 2023, gp3 encrypted root volume, IMDSv2 enforced, SSM + CloudWatch ready
- **Auto Scaling Group** — private subnets, ELB health checks, rolling instance refresh
- **Application Load Balancer** — internet-facing, public subnets, access logs to S3
- **Target Group** — HTTP:80, configurable health check path
- **HTTP Listener** — forwards to TG (or redirects to HTTPS when `certificate_arn` is set)
- **HTTPS Listener** — optional, created only when `certificate_arn` is provided

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
