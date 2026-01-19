# ==========================================
# 1. IAM ROLE PARA EL CLUSTER (El Jefe)
# ==========================================
# Definimos el rol: "Hola AWS, soy un servicio EKS y quiero permiso para actuar"
resource "aws_iam_role" "cluster_role" {
name = "${var.prefix}-eks-cluster-role"

assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
      Service = "eks.amazonaws.com"
    }
  }]
})

tags = var.tags
}

# Le pegamos la tarjeta de acceso oficial de Amazon para gestionar clusters
resource "aws_iam_role_policy_attachment" "cluster_policy" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
role       = aws_iam_role.cluster_role.name
}

# ==========================================
# 2. IAM ROLE PARA LOS NODOS (Los Obreros)
# ==========================================
# Definimos el rol: "Hola AWS, soy una máquina EC2 y quiero trabajar para Kubernetes"
resource "aws_iam_role" "node_role" {
name = "${var.prefix}-eks-node-role"

assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
      Service = "ec2.amazonaws.com"
    }
  }]
})

tags = var.tags
}

# Permiso 1: Para que el nodo se registre en el cluster
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
role       = aws_iam_role.node_role.name
}

# Permiso 2: Para gestionar la red (IPs) de los pods
resource "aws_iam_role_policy_attachment" "cni_policy" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
role       = aws_iam_role.node_role.name
}

# Permiso 3: Para descargar la imagen de Docker (CRÍTICO para tu Tetris)
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
role       = aws_iam_role.node_role.name
}

# ==========================================
# 3. EL CLUSTER EKS (El Cerebro)
# ==========================================
resource "aws_eks_cluster" "this" {
name     = "${var.prefix}-${var.cluster_name}"
role_arn = aws_iam_role.cluster_role.arn # Usa el rol del paso 1
version  = "1.30" # Usamos una versión moderna fija (la de tu compañero 1.22 es antigua)

vpc_config {
  subnet_ids = var.subnet_ids # Las subnets que vienen del módulo VPC
  
  # IMPORTANTE: Como no tenemos VPN, necesitamos acceder desde internet
  endpoint_public_access = true 
  endpoint_private_access = false
}

# Nos aseguramos de que los permisos estén listos antes de crear el cluster
depends_on = [
  aws_iam_role_policy_attachment.cluster_policy
]

tags = var.tags
}

# ==========================================
# 4. EL GRUPO DE NODOS (Los Músculos)
# ==========================================
resource "aws_eks_node_group" "this" {
cluster_name    = aws_eks_cluster.this.name
node_group_name = "${var.prefix}-node-group"
node_role_arn   = aws_iam_role.node_role.arn # Usa el rol del paso 2
subnet_ids      = var.subnet_ids

# Configuración de los servidores
instance_types = [var.instance_type] # ej: t3.medium

scaling_config {
  desired_size = var.desired_size
  max_size     = var.max_size
  min_size     = var.min_size
}

# Dependencias vitales
depends_on = [
  aws_iam_role_policy_attachment.worker_node_policy,
  aws_iam_role_policy_attachment.cni_policy,
  aws_iam_role_policy_attachment.ecr_read_only,
]

tags = var.tags
}