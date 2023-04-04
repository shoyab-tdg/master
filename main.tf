provider "aws"{
  region   = "us-east-1"
  access_key = "AKIAXHTMLUJ623WCTBKN"
  secret_key = "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"

}

resource "aws_vpc" "dev-vpc"{
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
   

  }
}
resource "aws_subnet" "dev-subnet1" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = var.subet_cidr_block
  availability_zone =var.avail_zone
   tags = {
    Name: "${var.env_prefix}-Shoyab-subnet1"
    
  }
}
resource "aws_internet_gateway" "my-igw"{
  vpc_id = aws_vpc.dev-vpc.id
   tags = {
    Name: "${var.env_prefix}-igw"
  }
}
resource "aws_default_route_table" "main-rtb"{
  default_route_table_id = aws_vpc.dev-vpc.default_route_table_id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id =aws_internet_gateway.my-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}

resource "aws_default_security_group" "default-sg"{
  vpc_id = aws_vpc.dev-vpc.id

  ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

 ingress{
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
     from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
 tags = {
    Name: "${var.env_prefix}-default-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
most_recent = true
owners = ["amazon"]
filter{
  name = "name"
  values =["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
}
}

resource "aws_instance""myapp-server-1"{
  ami = data.aws_ami.latest-amazon-linux-image.id 
  instance_type = var.instance_type

  subnet_id = aws_subnet.dev-subnet1.id 
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name ="server-keypair"

  tags={
    Name = "${var.env_prefix}-server"
  }
}

/*module "myapp-subnet"{
  source = "./module/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone 
  env.prefix =var.env.prefix
  vpc_id = aws_vpc.dev-vpc.id
  default_route_table.id = aws_vpc.dev-vpc.default_route_table.id

}

module "myapp-server"{
  source = "./module/webserver"
  vpc_id = aws_vpc.dev-vpc.id
  my_ip = var.my_ip
  env.prefix =var.env.prefix
  image_name = var.image_name 
  public_key_location = var.public_key_location
  instance_type = var.instance_type
  subnet_id = module.myapp_subnet.subnet.id 
  avail_zone = var.avail_zone 
 
 
  default_route_table.id = aws_vpc.dev-vpc.default_route_table.id

}*/
