provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

##ADDED 6/25/2025
locals {
  flattened_projects = [
    for project_key, project in var.project : {
      key                         = project_key
      environment                 = project.environment
      private_subnets_per_vpc     = project.private_subnets_per_vpc
      public_subnets_per_vpc      = project.public_subnets_per_vpc
      instances_per_subnet        = project.instances_per_subnet
      instance_type               = project.instance_type
    }
  ]
}

#NEW VPC MODUKE ADDED 6/27/2025
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "example-vpc"
  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 1)

  public_subnets = ["10.0.1.0/24"]

  enable_nat_gateway      = false
  create_igw              = true
  map_public_ip_on_launch = true

  tags = {
    Project = "example"
  }
}



#NEW APP SECURITY GROUP 6/27/2025
module "app_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "example-app-sg"
  description = "Allow SSH, HTTP, HTTPS inbound"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "SSH"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "HTTPS"
    }
  ]

  # Allow all outbound traffic by default (module default)
}




module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "4.9.0"
  
  #ADDED 6/27/2025
  #for_each = var.project
# For lb_security_group
  for_each = {
    for p in local.flattened_projects : p.key => p
    if p.private_subnets_per_vpc > 0 || p.public_subnets_per_vpc > 0
  }


  name = "load-balancer-sg-${each.key}-${each.value.environment}"
  description = "Security group for load balancer with HTTP ports open within VPC"
  vpc_id      = module.vpc[each.key].vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

#ADDED 6/27/2024
resource "random_string" "lb_id" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

#ADDED NEW ELB MODULE
module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "3.0.1"

  for_each = {
    for p in local.flattened_projects : p.key => p
    if p.public_subnets_per_vpc > 0 || p.private_subnets_per_vpc > 0
  }

  name              = local.elb_names[each.key]
  internal          = false
  security_groups   = [module.lb_security_group[each.key].security_group_id]
  subnets           = each.value.public_subnets_per_vpc > 0 ? module.vpc[each.key].public_subnets : module.vpc[each.key].private_subnets
  number_of_instances = length(module.ec2_instances[each.key].instance_ids)
  instances           = module.ec2_instances[each.key].instance_ids

  listener = [{
    instance_port      = "80"
    instance_protocol  = "HTTP"
    lb_port            = "443"
    lb_protocol        = "HTTPS"
    ssl_certificate_id = var.ssl_certificate_id
  }]

  health_check = {
    target              = "HTTP:80/index.html"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }

  depends_on = [module.ec2_instances]
}



#ADDED 6/27/2025
locals {
  elb_names = {
    for k, v in var.project : k =>
    k == "maps"
    ? "maps-demo-pabrennan-com" # ELB name can't have dots
    : trimsuffix(
        substr(
          join(
            "",
            regexall("[a-zA-Z0-9-]", join("-", ["lb", random_string.lb_id.result, k, v.environment]))
          ),
          0,
          32
        ),
        "-"
      )
  }

  route53_names = {
    for k, v in var.project : k =>
    k == "maps"
    ? "maps.demo.pabrennan.com" # Valid for Route53
    : local.elb_names[k]
  }
}

#NEW EC2 INSSTANCE MNODE 6/26/2025
module "ec2_instances" {
  source = "./modules/aws-instance"

  for_each = {
    for p in local.flattened_projects : p.key => p
    if p.private_subnets_per_vpc > 0 || p.public_subnets_per_vpc > 0
  }

  instance_count = each.value.instances_per_subnet * (
    each.value.private_subnets_per_vpc > 0
      ? length(module.vpc[each.key].private_subnets)
      : length(module.vpc[each.key].public_subnets)
  )
  subnet_ids = each.value.private_subnets_per_vpc > 0 ? module.vpc[each.key].private_subnets : module.vpc[each.key].public_subnets

  associate_public_ip_address = each.value.public_subnets_per_vpc > 0

  instance_type      = each.value.instance_type
  security_group_ids = [module.app_security_group[each.key].security_group_id]
  project_name       = each.key
  environment        = each.value.environment
  ssh_key_name       = var.ssh_key_name
}


#ADDED 6/26/2025
resource "aws_key_pair" "deployer" {
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}
