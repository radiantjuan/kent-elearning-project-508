provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"  # Use the latest stable version of the VPC module

  name = "K230925-radiantcjuan-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false  # No NAT gateway to avoid extra costs

  enable_dns_support    = true
  enable_dns_hostnames  = true
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.17"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets

  # Optional: Define IAM role for the EKS cluster
  # create_iam_role = true
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "eks-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = module.vpc.public_subnets

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_capacity
    min_size     = var.min_capacity
  }

  instance_types = [var.instance_type]

  tags = {
    Name = "eks-node-group"
  }
}

resource "aws_iam_role" "eks_node_role" {
  name = "eksNodeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cloudwatch_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn  = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "The security group ID of the EKS cluster."
  value       = module.eks.cluster_security_group_id
}

output "kubeconfig" {
  description = "The kubeconfig file for accessing the EKS cluster."
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}
