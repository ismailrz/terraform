terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = local.common_tags
  }
}

data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name               = "${var.project_name}-${var.environment}"
  vpc_cidr           = var.vpc_cidr
  single_nat_gateway = var.single_nat_gateway
  tags               = local.common_tags
}

module "security_groups" {
  source = "../../modules/security_groups"

  name   = "${var.project_name}-${var.environment}"
  vpc_id = module.vpc.vpc_id
  tags   = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  name = "${var.project_name}-${var.environment}"
  tags = local.common_tags
}

module "ec2_asg" {
  source = "../../modules/ec2_asg"

  name                  = "${var.project_name}-${var.environment}"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  ec2_security_group_id = module.security_groups.ec2_security_group_id
  instance_profile_name = module.iam.instance_profile_name
  aws_account_id        = data.aws_caller_identity.current.account_id

  instance_type              = var.instance_type
  min_size                   = var.asg_min_size
  max_size                   = var.asg_max_size
  desired_capacity           = var.asg_desired_capacity
  health_check_path          = var.health_check_path
  certificate_arn            = var.certificate_arn
  enable_deletion_protection = var.enable_deletion_protection
  user_data                  = var.user_data
  scaling_cpu_target         = var.scaling_cpu_target
  scaling_requests_target    = var.scaling_requests_target
  scaling_warmup_seconds     = var.scaling_warmup_seconds

  tags = local.common_tags
}
