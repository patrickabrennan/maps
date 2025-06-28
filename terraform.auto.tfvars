aws_region             = "us-east-2"
ssl_certificate_id     = "arn:aws:acm:us-east-2:285942769742:certificate/2b1fade2-4584-459b-9098-76e940a7da18"
ssh_key_name = "pb-ssh-key"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZUw1yvE8A15vPk48W637EjMi/xAtugZJRyxHzmNvcsPRgkJ2ox7owgf3vJNC20yzcArV83uPZnec7lfjfWggVBpI/VETgaeeGC1UB6ilu0WO6MPD5BpVhg5HknMXtaVfmQHdG3Ycw0Ilg8DGFWjTRneTV7mpu00TYQZELBrShE9iVG5RCVQ3Fka8xt9wnCVYj/Qjo4VQyfi36zJe47/XH/Oji2ANVijpPMKHPYQizrm0t/WTdzy2iSFUJhHRqOjjQx79KTWIks2ig3jSFguzztwYKmxDRbb7M7AHS1qutVr5MSeJSxtneNYLYgxwKOx5el0zXIqD/a4ow4TlZJDjStnTFg+RaHXJ4E8sJ6zWEmIlisjKgVPpud1MPkUxRO7kuxiZ37/TxaTkVLDGWylTtNAdQj+ih2h+FtPtHE3VJkOIAI3FTX1GSEdTQoH5eEs/xgLYCIg4ANcSEOoyaJqVgFnQInmXuXd0Hq391AMcOmWugPCioVHcJeanSSeQxw0M= sap"
vpc_cidr_block = "10.0.0.0/16"

project = {
  maps = {
    environment             = "prod"
    private_subnets_per_vpc = 0
    public_subnets_per_vpc  = 1
    instances_per_subnet    = 1
    instance_type           = "t3.micro"
  },
  backend = {
    environment             = "maps"
    private_subnets_per_vpc = 0
    public_subnets_per_vpc  = 0
    instances_per_subnet    = 1
    instance_type           = "t3.small"
  }
}
