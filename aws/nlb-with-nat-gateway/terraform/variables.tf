variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "availability_zone" {
  description = "Availability zone for subnets"
  type        = string
  default     = "ap-southeast-1a"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for the VMs"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances (Amazon Linux 2023 in ap-southeast-1)"
  type        = string
  default     = "ami-0532913178263be11"
}

variable "public_key_path" {
  description = "Path to the SSH public key file to upload as an EC2 Key Pair"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "nlb_listener_port" {
  description = "Port the NLB listener accepts traffic on"
  type        = number
  default     = 80
}
