resource "aws_eks_cluster" "eks" {
  name     = "evershop-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = concat(module.vpc.public_subnets) # Assuming you want public subnets here

    endpoint_public_access = true
    endpoint_private_access = false
  }

  tags = {
    Name = "evershop-eks-cluster"
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "evershop-eks-node-group"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = module.vpc.private_subnets # Use private subnets for better security
  instance_types  = ["t3.medium"]
  disk_size       = 20

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3 # Set min_size to 3 to ensure 3 nodes
  }

  labels = {
    "app" = "evershop"
    "env" = "development"
  }

  remote_access {
    ec2_ssh_key               = "dev-shree"
    source_security_group_ids = [aws_security_group.eks_worker_nodes.id]
  }

  tags = {
    Name = "eks-node-group"
    Environment = "Development"
  }

  depends_on = [aws_eks_cluster.eks]
}

resource "aws_launch_template" "worker_template" {
  name          = "eks-worker-template"
  instance_type = "t3.medium"

  network_interfaces {
    security_groups = [aws_security_group.eks_worker_nodes.id]
  }

  key_name = "dev-shree"

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-worker-node"
    }
  }
}

resource "aws_security_group" "eks_worker_nodes" {
  name   = "eks-worker-nodes-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow all traffic from EKS control plane"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-worker-nodes-sg"
  }
}
