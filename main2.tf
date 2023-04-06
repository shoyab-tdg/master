provider "task"{
  region   = "us-east-1"
  access_key = "AKIAXHTMLUJ6YBZ7TDGQ "
  secret_key = "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"

}

data "aws_vpc" "vpc" {
  tags = {
    Name = "my-vpc"
  }
}
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "my-security-group"
  description = "Security group for my EC2 instance"
  vpc_id      = data.aws_vpc.vpc.id

 ingress_cidr_blocks = [
    "0.0.0.0/0"
  ]

  ingress_rules = [
    {
      description      = "Allow SSH access"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    },
     {
      description      = "Allow HTTP access"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]
}
module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                 = "my-ec2-instance"
  instance_count       = 1
  ami                  = var.ami_id
  instance_type        = var.instance_type
  key_name             = var.key_pair
  vpc_security_group_ids = [module.sg.this_security_group_id]

  tags = {
    Name = "my-ec2-instance"
  }
}

/*
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}*/
