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
# EKS Cluster (باستخدام Cluster موجود)
# ----------------------------
data "aws_eks_cluster" "existing" {
  name = "my-test-eks"
}

data "aws_eks_cluster_auth" "existing" {
  name = data.aws_eks_cluster.existing.name
}

# ----------------------------
# EKS Node Group (باستخدام Cluster موجود)
# ----------------------------
resource "aws_eks_node_group" "node-grp" {
  cluster_name    = data.aws_eks_cluster.existing.name
  node_group_name = var.node_group_name
  node_role_arn   = "arn:aws:iam::851725605085:role/ExistingWorkerRole"
  subnet_ids      = [data.aws_subnet.subnet-1.id, data.aws_subnet.subnet-2.id]
  capacity_type   = "ON_DEMAND"
  disk_size       = 20
  instance_types  = ["t2.large"]

  labels = {
    env = "dev"
  }

  tags = {
    Name = "project-eks-node-group"
  }

  scaling_config {
    desired_size = 3
    max_size     = 10
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }
}

# ----------------------------
# OIDC Provider for ServiceAccount IAM Roles
# ----------------------------
data "tls_certificate" "oidc_thumbprint" {
  url = data.aws_eks_cluster.existing.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.existing.identity[0].oidc[0].issuer
}
