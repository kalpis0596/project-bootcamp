#Create aws vpc
resource "aws_vpc" "wp-vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = "10.0.0.0/24"
  instance_tenancy     = "default"

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

#Create aws subnet in AZ1
resource "aws_subnet" "wp-subnet-public1" {
  vpc_id            = aws_vpc.wp-vpc.id
  cidr_block        = "10.0.0.0/26"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "${var.project_name}-subnet-public1"
  }
}

#create internet gateway
resource "aws_internet_gateway" "wp-igw" {
  vpc_id = aws_vpc.wp-vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

#Create route table
resource "aws_route_table" "wp-table_route" {
  vpc_id = aws_vpc.wp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wp-igw.id
  }

  tags = {
    Name = "${var.project_name}-table_route"
  }
}

#create routable association with public subnet
resource "aws_route_table_association" "wp-association" {
  subnet_id      = aws_subnet.wp-subnet-public1.id
  route_table_id = aws_route_table.wp-table_route.id
}

#Create security group
resource "aws_security_group" "wp-security_group" {
  name        = "${var.project_name}-security-group"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.wp-vpc.id

  tags = {
    Name = "${var.project_name}-security-group"
  }

  #add inbound port 443 (https)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #add inbound port 80 (http)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #add inbound port 22 (ssh)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #create outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#create ec2
resource "aws_instance" "wp-server" {
  ami           = "ami-003c463c8207b4dfa"
  instance_type = "t2.micro"
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  #Attached the created security group
  vpc_security_group_ids = [aws_security_group.wp-security_group.id]

  #Deploy into the created public subnet before
  subnet_id                   = aws_subnet.wp-subnet-public1.id
  private_ip                  = "10.0.0.5"
  associate_public_ip_address = "true"
  key_name                    = "webserverkapis"

  tags = {
    Name = "${var.project_name}-server"
  }
}

# Use data to look up zone info
data "cloudflare_zone" "wp-zone" {
  name = "khafiz.me"
}

# Add a record to the domain
resource "cloudflare_record" "wp-record" {
  zone_id = data.cloudflare_zone.wp-zone.id
  name    = "@"
  content = aws_instance.wp-server.public_ip
  type    = "A"
  ttl     = 1
  proxied = false
}
