# Specify the provider and region
provider "aws" {
  region     = "ap-southeast-2" # Sydney region
}

# Retrieve AWS account information
data "aws_caller_identity" "current" {}

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

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from any IP
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

# Enable AWS Config for resource tracking
resource "aws_config_configuration_recorder" "main" {
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
    include_global_resource_types = true
  }
}

resource "aws_iam_role" "config_role" {
  name = "config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "config.amazonaws.com"
      }
    }]
  })
}

resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = aws_s3_bucket.config_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.config_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.config_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetBucketAcl",
        Resource = "${aws_s3_bucket.config_bucket.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_role_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_delivery_channel" "main" {
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
}

# S3 bucket for AWS Config logs
resource "aws_s3_bucket" "config_bucket" {
  bucket = "my-config-logs-bucket"
}

# Enable CloudTrail for auditing and logging
resource "aws_cloudtrail" "main" {
  name                          = "cloudtrail"
  s3_bucket_name                = aws_s3_bucket.config_bucket.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
}

# Enable CloudWatch for monitoring and logging
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/monitoring/cloudwatch"
  retention_in_days = 30
}

# Outputs
output "instance_id" {
  value = aws_instance.web.id
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "config_recorder_status" {
  value = aws_config_configuration_recorder.main.name
}

output "cloudtrail_status" {
  value = aws_cloudtrail.main.name
}