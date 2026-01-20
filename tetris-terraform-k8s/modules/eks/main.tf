# IAM Roles (Se mantienen igual, usar nombres descriptivos aquí es correcto)
resource "aws_iam_role" "cluster_role" {
name = "${var.prefix}-eks-cluster-role"
assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = { Service = "eks.amazonaws.com" }
  }]
})
tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role" "node_role" {
name = "${var.prefix}-eks-node-role"
assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = { Service = "ec2.amazonaws.com" }
  }]
})
tags = var.tags
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
role       = aws_iam_role.node_role.name
}

# --- CLUSTER ---
resource "aws_eks_cluster" "main" {
name     = "${var.prefix}-${var.cluster_name}"
role_arn = aws_iam_role.cluster_role.arn

# AQUI EL CAMBIO: Usamos la variable
version  = var.engine_version 

vpc_config {
  subnet_ids              = var.subnet_ids
  endpoint_public_access  = true 
  endpoint_private_access = false
}

depends_on = [aws_iam_role_policy_attachment.cluster_policy]
tags       = var.tags
}

# --- NODE GROUP ---
resource "aws_eks_node_group" "main" {
cluster_name    = aws_eks_cluster.main.name
node_group_name = "${var.prefix}-node-group"
node_role_arn   = aws_iam_role.node_role.arn
subnet_ids      = var.subnet_ids

instance_types = [var.instance_type]

scaling_config {
  desired_size = var.desired_size
  max_size     = var.max_size
  min_size     = var.min_size
}

depends_on = [
  aws_iam_role_policy_attachment.worker_node_policy,
  aws_iam_role_policy_attachment.cni_policy,
  aws_iam_role_policy_attachment.ecr_read_only,
]
tags = var.tags
}