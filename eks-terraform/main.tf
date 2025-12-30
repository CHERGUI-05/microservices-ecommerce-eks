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
# Existing EKS Cluster
# ----------------------------
data "aws_eks_cluster" "existing" {
  name = "my-test-eks"
}

data "aws_eks_cluster_auth" "existing" {
  name = data.aws_eks_cluster.existing.name
}

# ----------------------------
# الملاحظات:
# - لم نعد نحاول إنشاء Node Group
# - لم نعد نحاول إنشاء IAM OIDC Provider
# - Terraform الآن سيكتفي بالقراءة فقط من Cluster الموجود
# ----------------------------
