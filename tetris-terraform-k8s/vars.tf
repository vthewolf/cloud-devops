# --- Identidad del Proyecto ---
variable "project" {
type        = string
description = "Nombre del proyecto (ej: tetris)"
}

variable "environment" {
type        = string
description = "Entorno de despliegue (ej: pre, pro)"
}

# --- Red (Network) ---
variable "vpc_cidr_block" {
type        = string
description = "Rango IP de la VPC"
}

variable "public_subnet_params" {
type        = map(any)
description = "Mapa de configuración de subnets públicas"
}

# --- Kubernetes (EKS) ---
variable "eks_ng_instance_type" {
type = string
}
variable "eks_ng_desired_size" {
type = number
}
variable "eks_ng_max_size" {
type = number
}
variable "eks_ng_min_size" {
type = number
}
variable "eks_engine_version" {
type = string
}

# --- Almacenamiento (S3) ---
variable "bucket_params" {
type        = map(any)
description = "Mapa de configuración de buckets S3"
}