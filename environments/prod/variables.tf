variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev / staging / prod)"
  type        = string
}

variable "project_name" {
  description = "Project name — used as a prefix for all resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway instead of one per AZ"
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "ASG minimum instance count"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "ASG maximum instance count"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "ASG desired instance count"
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "ALB health check path"
  type        = string
  default     = "/"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS; leave empty for HTTP-only"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Enable ALB deletion protection"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "User data shell script run on instance launch"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from $(hostname -f) [${environment}]</h1>" > /var/www/html/index.html
  EOF
}
