#ADDED 6/28/2025
#variable "instance_count" {}
#variable "subnet_ids" {}
#variable "instance_type" {}
#variable "security_group_ids" {}
#variable "project_name" {}
#variable "environment" {}
#variable "ssh_key_name" {}
#variable "associate_public_ip_address" {
#  type    = bool
#  default = true
#}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "this" {
  count                     = var.instance_count
  ami                       = data.aws_ami.amazon_linux.id
  instance_type             = var.instance_type
  subnet_id                 = element(var.subnet_ids, count.index % length(var.subnet_ids))
  vpc_security_group_ids    = var.security_group_ids
  key_name                  = var.ssh_key_name
  associate_public_ip_address = var.associate_public_ip_address

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              systemctl enable docker
              docker run --rm -d -p 80:80 -p 443:443 --name myweb patrickabrennan/myweb
              EOF

  tags = {
    Name        = "${var.project_name}-${var.environment}-instance-${count.index}"
    Environment = var.environment
    Project     = var.project_name
  }
}




#variable "ssh_key_name" {
#  description = "Name of the SSH key pair"
#  type        = string
#  default     = ""
#}



#data "aws_ami" "amazon_linux" {
#  most_recent = true
#  owners      = ["amazon"]

#  filter {
#    name   = "name"
#    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#  }
#}

#resource "aws_instance" "app" {
#  count = var.instance_count

#  ami           = data.aws_ami.amazon_linux.id
#  instance_type = var.instance_type

#  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
#  vpc_security_group_ids = var.security_group_ids

  #added public IP 12/15/2023
# associate_public_ip_address = true

  #ADDED 6/26/2025
#  key_name = var.ssh_key_name
#  user_data = <<-EOF
#  #!/bin/bash
#  echo "Installing Pat's Google Maps Application"

  # Update and install Docker properly
 # sudo yum update -y
 # sudo amazon-linux-extras install docker -y
 # sudo systemctl start docker
 # sudo systemctl enable docker

  # Add ec2-user to docker group
  #sudo usermod -aG docker ec2-user

  # Allow docker socket access (optional, may be insecure)
  #sudo chmod 666 /var/run/docker.sock

  # Run your Docker container
  #docker run --rm -d -p 80:80 -p 443:443 --name myweb patrickabrennan/myweb

  #echo "Completed Installing Pat's Google Maps Application"
  #EOF

  #user_data = <<-EOF
  #  #!/bin/bash
  #  echo "Installing Pat's Google Maps Application"
  #  sudo bash -c 'yum update -y'
  #  sudo bash -c 'yum install docker -y'
  #  sudo bash -c 'systemctl start docker' 
  #  sudo bash -c 'systemctl enable docker'
  #  sudo bash -c 'chmod 666 /var/run/docker.sock'
  #  docker run --rm -d -p 80:80 -p 443:443 --name myweb patrickabrennan/myweb
  #  echo "Completed Installing Pat's Google Maps Application"
    #sudo yum update -y
    #sudo yum install httpd -y
    #sudo systemctl enable httpd
    #sudo systemctl start httpd
    #echo "<html><body><div>Hello, world!</div></body></html>" > /var/www/html/index.html
  #EOF

  #tags = {
  #  Terraform   = "true"
  #  Project     = var.project_name
  #  Environment = var.environment
 # }
#}
