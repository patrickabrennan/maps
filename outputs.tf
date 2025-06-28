#ADDED 6/27/2025
output "elb_dns_names" {
  description = "Map of project/environment to Route53 DNS names for ELBs"
  value = {
    for k, v in var.project :
    "${k}-${v.environment}" => aws_route53_record.elb_alias[k].fqdn
    if contains(keys(aws_route53_record.elb_alias), k)
  }
}

output "elb_names" {
  description = "Elastic Load Balancer DNS names per project"
  value = {
    for k, v in var.project :
    "${k}-${v.environment}" => module.elb_http[k].elb_dns_name
    if contains(keys(module.elb_http), k)
  }
}

output "ec2_instances_per_project" {
  description = "EC2 instance IDs per project"
  value = {
    for k, v in var.project :
    "${k}-${v.environment}" => module.ec2_instances[k].instance_ids
    if contains(keys(module.ec2_instances), k)
  }
}

