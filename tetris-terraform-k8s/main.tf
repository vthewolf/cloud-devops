module "s3_backend" {
source = "./modules/s3"

prefix      = "dev"
bucket_name = "tf-tetris-victor-2026"

tags = {
  Purpose = "Terraform Backend"
}

bucket_versioning = true
bucket_acl        = "private"
}

module "vpc" {
source = "./modules/vpc"

prefix = "dev"

# Usamos el rango estándar. 
# 10.0.0.0/16 te da 65.000 IPs (de sobra).
vpc_cidr_block = "10.0.0.0/16"

# Definimos 2 subnets en 2 zonas distintas (Requisito de EKS)
public_subnets = {
  "subnet-1" = { cidr_block = "10.0.1.0/24", availability_zone = "eu-north-1a" }
  "subnet-2" = { cidr_block = "10.0.2.0/24", availability_zone = "eu-north-1b" }
}

tags = {
  Environment = "dev"
  Project     = "tetris-k8s"
}
}

module "eks" {
source = "./modules/eks"

prefix       = "tetris-dev"
cluster_name = "cluster-01"

# CONEXIÓN MÁGICA:
# Le pasamos los IDs que salen del módulo VPC
vpc_id     = module.vpc.vpc_id
subnet_ids = module.vpc.public_subnet_ids

# Configuración económica
instance_type = "t3.small" # O t3.medium si quieres ir sobrado
desired_size  = 2

tags = {
  Environment = "dev"
  Project     = "tetris-k8s"
}
}

module "ecr" {
source = "./modules/registry"

prefix = "tetris-dev"
name   = "app" # El resultado será "tetris-dev-app"

tags = {
  Environment = "dev"
  Project     = "tetris-k8s"
}
}