output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the ALB — open this in a browser to verify the deployment"
  value       = module.ec2_asg.alb_dns_name
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.ec2_asg.autoscaling_group_name
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = module.ec2_asg.launch_template_id
}
