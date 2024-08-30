# Specify the provider and region
provider "aws" {
  region     = "ap-southeast-2" # Sydney region
}

# Define variables for AWS credentials
variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH Public Key"
  type        = string
  sensitive   = true
}

# Security group for the EC2 instance
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH and outbound traffic"
  vpc_id      = "vpc-030a1d58748f564b9"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust as needed
  }

  tags = {
    Name = "ec2-sg"
  }
}

# Security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MariaDB traffic from EC2"
  vpc_id      = "vpc-030a1d58748f564b9"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

resource "aws_key_pair" "admin_key_pair" {
  key_name   = "admin-key-pair"
  public_key = var.ssh_public_key
}

# Create an EC2 instance within the free tier
resource "aws_instance" "web" {
  ami           = "ami-0375ab65ee943a2a6" # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  instance_type = "t2.micro"
  availability_zone = "ap-southeast-2a"  # Specify the desired Availability Zone
  security_groups = [aws_security_group.ec2_sg.name]
  key_name = aws_key_pair.admin_key_pair.key_name  # Specify the key pair
  user_data = <<-EOF
                #!/bin/bash
                # Update the package index
                sudo apt-get update -y

                # Install Docker
                sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
                sudo apt-get update -y
                sudo apt-get install -y docker-ce

                # Start and enable Docker service
                sudo systemctl start docker
                sudo systemctl enable docker
                EOF

  tags = {
    Name = "k230925-radiantcjuan-kent-elearning-instance"
  }
}

# Create an RDS instance with MariaDB
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  db_name              = "kentelearningdb"
  engine               = "mariadb"
  engine_version       = "10.11.8"
  instance_class       = "db.t3.micro"
  username             = "kentadmin"
  password             = "TestingPassword"
  skip_final_snapshot  = true
  availability_zone = "ap-southeast-2a"  # Specify the desired Availability Zone
  vpc_security_group_ids = [aws_security_group.rds_sg.id]  # Attach the RDS security group
}

# Outputs
output "instance_id" {
  value = aws_instance.web.id
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}