# ==========================================
# 1. Configuración Local (Estándar Empresa)
# ==========================================
locals {
# Generamos el prefijo automáticamente: "tetris-pre"
prefix = "victor-${var.project}-${var.environment}"

# Calculamos los tags automáticamente
tags = {
  "project"     = var.project
  "environment" = var.environment
}
}

# ==========================================
# 2. Módulo de Almacenamiento (S3) - Iterativo
# ==========================================
# Ahora usamos 'for_each' para leer el mapa 'bucket_params' del pre.tfvars
module "s3" {
source   = "./modules/s3"
for_each = var.bucket_params 

prefix = local.prefix
tags   = local.tags

# Datos específicos que vienen del mapa en .tfvars
bucket_name           = each.key 
bucket_acl            = each.value.bucket_acl
bucket_versioning     = each.value.bucket_versioning
bucket_lifecycle_rule = each.value.bucket_lifecycle_rule
}

# ==========================================
# 3. Módulo de Red (VPC)
# ==========================================
module "vpc" {
source = "./modules/vpc"

prefix = local.prefix
tags   = local.tags

vpc_cidr_block = var.vpc_cidr_block

# CAMBIO CLAVE: Usamos el nombre nuevo de variable que pide tu empresa
public_subnet_params = var.public_subnet_params
}

# ==========================================
# 4. Módulo de Kubernetes (EKS)
# ==========================================
module "eks" {
source = "./modules/eks"

prefix = local.prefix
tags = {}

cluster_name = "cluster-01" 

# Inyección de dependencias (Outputs del módulo VPC)
vpc_id     = module.vpc.vpc_id
subnet_ids = module.vpc.public_subnet_ids

# Configuración del nodo desde variables (pre.tfvars)
instance_type  = var.eks_ng_instance_type
desired_size   = var.eks_ng_desired_size
max_size       = var.eks_ng_max_size
min_size       = var.eks_ng_min_size

# Nueva variable obligatoria
engine_version = var.eks_engine_version
}

# ==========================================
# 5. Módulo de Registro (ECR)
# ==========================================
# Lo dejamos adaptado a variables locales por si decides activarlo,
# pero recuerda que dijimos que para imagen pública no hace falta.
module "ecr" {
source = "./modules/ecr"

prefix = local.prefix
tags   = local.tags
name   = "app"
}