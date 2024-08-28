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

# Define a security group for the EC2 instance
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance within the free tier
resource "aws_instance" "web" {
  ami           = "ami-0375ab65ee943a2a6" # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_ssh.name]

  tags = {
    Name = "k230925-radiantcjuan-kent-elearning-instance"
  }
}

# Create an RDS instance with MariaDB
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mariadb"
  instance_class       = "db.t2.micro"
  username             = "kentadmin"
  password             = "p@55w0rd"
  parameter_group_name = "default.mariadb10.4"
  skip_final_snapshot  = true

  tags = {
    Name = "k230925-radiantcjuan-kent-elearning-rds"
  }
}

# Outputs
output "instance_id" {
  value = aws_instance.web.id
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}