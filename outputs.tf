#ADDED 6/27/2025
output "elb_dns_names" {
  description = "DNS names of Route53 records pointing to ELBs"
  value = {
    for k, v in aws_route53_record.elb_alias : "${v.name}" => v.fqdn
  }
}

output "elb_names" {
  description = "Names of the ELBs created"
  value = {
    for k, v in module.elb_http : k => v.elb_dns_name
  }
}

output "ec2_instances_per_project" {
  description = "EC2 instance IDs per project/environment"
  value = {
    for k, v in module.ec2_instances : k => v.instance_ids
  }
}
