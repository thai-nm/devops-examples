# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "nlb-nat-vpc" }
}

# Subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = { Name = "nlb-nat-public" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = { Name = "nlb-nat-private" }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "nlb-nat-igw" }
}

# Elastic IP + NAT Gateway (in public subnet)
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = { Name = "nlb-nat-eip" }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = { Name = "nlb-nat-natgw" }

  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "nlb-nat-public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = { Name = "nlb-nat-private-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Security Group for VMs
resource "aws_security_group" "vm" {
  name        = "nlb-nat-vm-sg"
  description = "Allow inbound from NLB subnet and client CIDR; allow all outbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "From NLB subnet"
    from_port   = var.nlb_listener_port
    to_port     = var.nlb_listener_port
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr]
  }

  ingress {
    description = "From client CIDR"
    from_port   = var.nlb_listener_port
    to_port     = var.nlb_listener_port
    protocol    = "tcp"
    cidr_blocks = [var.client_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "nlb-nat-vm-sg" }
}

# EC2 Instances (private subnet, no public IP)
resource "aws_instance" "vm1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.vm.id]
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null

  tags = { Name = "nlb-nat-vm1" }
}

resource "aws_instance" "vm2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.vm.id]
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null

  tags = { Name = "nlb-nat-vm2" }
}

# Network Load Balancer (internet-facing, in public subnet)
resource "aws_lb" "nlb" {
  name               = "nlb-nat-nlb"
  load_balancer_type = "network"
  internal           = false
  subnets            = [aws_subnet.public.id]

  tags = { Name = "nlb-nat-nlb" }
}

# Target Group (instance type)
resource "aws_lb_target_group" "vms" {
  name        = "nlb-nat-tg"
  port        = var.nlb_listener_port
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }

  tags = { Name = "nlb-nat-tg" }
}

resource "aws_lb_target_group_attachment" "vm1" {
  target_group_arn = aws_lb_target_group.vms.arn
  target_id        = aws_instance.vm1.id
  port             = var.nlb_listener_port
}

resource "aws_lb_target_group_attachment" "vm2" {
  target_group_arn = aws_lb_target_group.vms.arn
  target_id        = aws_instance.vm2.id
  port             = var.nlb_listener_port
}

# NLB Listener
resource "aws_lb_listener" "tcp" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = var.nlb_listener_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vms.arn
  }
}
