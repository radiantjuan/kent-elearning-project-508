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

# Create an EC2 instance within the free tier
resource "aws_instance" "web" {
  ami           = "ami-0375ab65ee943a2a6" # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  instance_type = "t2.micro"

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
}

# Outputs
output "instance_id" {
  value = aws_instance.web.id
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}