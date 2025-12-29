# ----------------------------
# Backend محلي لتخزين الـ state
# ----------------------------
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# ----------------------------
# Provider
# ----------------------------
provider "aws" {
  region = "us-east-1"
}

# ----------------------------
# IAM Roles (استخدم بيانات جاهزة بدل الإنشاء)
# ----------------------------
# إذا كان لديك أدوار جاهزة في الـ lab، استبدلي الأسماء هنا
data "aws_iam_role" "cluster_role" {
  name = "Existing-EKS-Cluster-Role"
}

data "aws_iam_role" "node_role" {
  name = "Existing-EKS-Node-Role"
}

# ----------------------------
# VPC and Subnet Data Sources
# ----------------------------
data "aws_vpc" "main" {
  tags = {
    Name = "Jumphost-vpc"
  }
}

data "aws_subnet" "subnet-1" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name   = "tag:Name"
    values = ["Public-Subnet-1"]
  }
}

data "aws_subnet" "subnet-2" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name   = "tag:Name"
    values = ["Public-subnet2"]
  }
}

data "aws_security_group" "selected" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name   = "tag:Name"
    values = ["Jumphost-sg"]
  }
}

# ----------------------------
# EKS Cluster
# ----------------------------
resource "aws_eks_cluster" "eks" {
  name     = "project-eks"
  role_arn = data.aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids         = [data.aws_subnet.subnet-1.id, data.aws_subnet.subnet-2.id]
    security_group_ids = [data.aws_security_group.selected.id]
  }

  tags = {
    Name        = "yaswanth-eks-cluster"
    Environment = "dev"
    Terraform   = "true"
  }
}

# ----------------------------
# EKS Node Group
# ----------------------------
resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "project-node-group"
  node_role_arn   = data.aws_iam_role.node_role.arn
  subnet_ids      = [data.aws_subnet.subnet-1.id, data.aws_subnet.subnet-2.id]
  capacity_type   = "ON_DEMAND"
  disk_size       = 20
  instance_types  = ["t3.small"]

  labels = {
    env = "dev"
  }

  tags = {
    Name = "project-eks-node-group"
  }

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
}

# ----------------------------
# ملاحظة: OIDC Provider محذوف مؤقتًا
# ----------------------------
# إذا كانت البيئة تسمح بإنشائه لاحقًا، يمكن إضافته مرة أخرى
