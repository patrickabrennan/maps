#ADDED 6/26/2025
variable "ssh_key_name" {
  description = "Name of the AWS SSH Key Pair"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH Public Key"
  type        = string
}

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

#ADDED 6-27-25
variable "ssl_certificate_id" {
  description = "ARN of the SSL certificate"
  type        = string
}

#NEW NESTED VARIABLES 6/25/25
variable "project" {
  type = map(any)
  default = {
    client-webapp = {
      environment              = "dev"
      private_subnets_per_vpc  = 2
      public_subnets_per_vpc   = 2
      instances_per_subnet     = 2
      instance_type            = "t2.micro"
    }
    client-api = {
      environment              = "prod"
      private_subnets_per_vpc  = 3
      public_subnets_per_vpc   = 3
      instances_per_subnet     = 1
      instance_type            = "t3.micro"
    }
  }
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24"
  ]
}
