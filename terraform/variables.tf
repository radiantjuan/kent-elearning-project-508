variable "region" {
  description = "The AWS region to create resources in."
  default     = "ap-southeast-2"
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  default     = "k230925-radiantjuan-cluster"
}

variable "cluster_version" {
  description = "The version of Kubernetes to use for the EKS cluster."
  default     = "1.30"
}

variable "desired_capacity" {
  description = "The desired number of worker nodes."
  default     = 1
}

variable "max_capacity" {
  description = "The maximum number of worker nodes."
  default     = 2
}

variable "min_capacity" {
  description = "The minimum number of worker nodes."
  default     = 1
}

variable "instance_type" {
  description = "The EC2 instance type for the worker nodes."
  default     = "t3.micro"
}
