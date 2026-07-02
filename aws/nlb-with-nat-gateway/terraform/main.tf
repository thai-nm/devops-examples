# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "vntechies-dev-vpc" }
}

# Subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = { Name = "vntechies-dev-public" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = { Name = "vntechies-dev-private" }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "vntechies-dev-igw" }
}

# # Elastic IP + NAT Gateway (in public subnet)
# resource "aws_eip" "nat" {
#   domain = "vpc"

#   tags = { Name = "vntechies-dev-eip-natgw" }
# }

# resource "aws_nat_gateway" "main" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public.id

#   tags = { Name = "vntechies-dev-natgw" }

#   depends_on = [aws_internet_gateway.main]
# }

# # Route Tables
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }

#   tags = { Name = "vntechies-dev-rtb-pub" }
# }

# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main.id
#   }

#   tags = { Name = "vntechies-dev-rtb-pri" }
# }

# resource "aws_route_table_association" "public" {
#   subnet_id      = aws_subnet.public.id
#   route_table_id = aws_route_table.public.id
# }

# resource "aws_route_table_association" "private" {
#   subnet_id      = aws_subnet.private.id
#   route_table_id = aws_route_table.private.id
# }

# # # Security Group for VMs
# resource "aws_security_group" "vm" {
#   name        = "vntechies-dev-sg-vm"
#   description = "Allow inbound from NLB subnet and client CIDR; allow all outbound"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description = "From NLB subnet"
#     from_port   = var.nlb_listener_port
#     to_port     = var.nlb_listener_port
#     protocol    = "tcp"
#     cidr_blocks = [var.public_subnet_cidr]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = { Name = "vntechies-dev-sg-vm" }
# }

# # SSH Key Pair
# resource "aws_key_pair" "deployer" {
#   key_name   = "vntechies-dev-key"
#   public_key = file(var.public_key_path)

#   tags = { Name = "vntechies-dev-key" }
# }

# # EC2 Instances (private subnet, no public IP)
# resource "aws_instance" "backend001" {
#   ami                    = var.ami_id
#   instance_type          = var.instance_type
#   subnet_id              = aws_subnet.private.id
#   vpc_security_group_ids = [aws_security_group.vm.id]
#   key_name               = aws_key_pair.deployer.key_name

#   tags = { Name = "vntechies-dev-vm-backend-001" }
# }

# resource "aws_instance" "backend002" {
#   ami                    = var.ami_id
#   instance_type          = var.instance_type
#   subnet_id              = aws_subnet.private.id
#   vpc_security_group_ids = [aws_security_group.vm.id]
#   key_name               = aws_key_pair.deployer.key_name

#   tags = { Name = "vntechies-dev-vm-backend-002" }
# }

# # Network Load Balancer (internet-facing, in public subnet)
# resource "aws_lb" "nlb" {
#   name               = "vntechies-dev-nlb-backend"
#   load_balancer_type = "network"
#   internal           = false
#   subnets            = [aws_subnet.public.id]

#   tags = { Name = "vntechies-dev-nlb-backend" }
# }

# # Target Group (instance type)
# resource "aws_lb_target_group" "backend" {
#   name        = "vntechies-dev-tg-backend"
#   port        = var.nlb_listener_port
#   protocol    = "TCP"
#   target_type = "instance"
#   vpc_id      = aws_vpc.main.id

#   health_check {
#     protocol = "TCP"
#     port     = "traffic-port"
#   }

#   tags = { Name = "vntechies-dev-tg-backend" }
# }

# resource "aws_lb_target_group_attachment" "backend001" {
#   target_group_arn = aws_lb_target_group.backend.arn
#   target_id        = aws_instance.backend001.id
#   port             = var.nlb_listener_port
# }

# resource "aws_lb_target_group_attachment" "backend002" {
#   target_group_arn = aws_lb_target_group.backend.arn
#   target_id        = aws_instance.backend002.id
#   port             = var.nlb_listener_port
# }

# # NLB Listener
# resource "aws_lb_listener" "tcp" {
#   load_balancer_arn = aws_lb.nlb.arn
#   port              = var.nlb_listener_port
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.backend.arn
#   }
# }
