variable "prefix" {
description = "Prefijo para los nombres"
type        = string
}

variable "cluster_name" {
description = "Nombre del cluster de Kubernetes"
type        = string
}

variable "vpc_id" {
description = "ID de la VPC"
type        = string
}

variable "subnet_ids" {
description = "Lista de IDs de subnets"
type        = list(string)
}

# Variable Nueva para conectar con pre.tfvars
variable "engine_version" {
description = "Versión de Kubernetes (ej: 1.30)"
type        = string
}

variable "instance_type" {
description = "Tipo de instancia EC2"
type        = string
# Sin default
}

variable "desired_size" {
description = "Número de nodos deseados"
type        = number
# Sin default
}

variable "max_size" {
description = "Número máximo de nodos"
type        = number
# Sin default
}

variable "min_size" {
description = "Número mínimo de nodos"
type        = number
# Sin default
}

variable "tags" {
description = "Etiquetas generales"
type        = map(string)
}