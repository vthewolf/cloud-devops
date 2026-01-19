variable "prefix" {
description = "Prefijo para los nombres"
type        = string
}

variable "cluster_name" {
description = "Nombre del cluster de Kubernetes"
type        = string
}

variable "vpc_id" {
description = "ID de la VPC donde se instalará"
type        = string
}

variable "subnet_ids" {
description = "Lista de IDs de subnets donde poner los nodos"
type        = list(string)
}

variable "instance_type" {
description = "Tipo de instancia EC2 para los nodos (ej: t3.small, t3.medium)"
type        = string
default     = "t3.medium"
}

variable "desired_size" {
description = "Número de nodos deseados"
type        = number
default     = 2
}

variable "max_size" {
description = "Número máximo de nodos (Auto Scaling)"
type        = number
default     = 3
}

variable "min_size" {
description = "Número mínimo de nodos"
type        = number
default     = 1
}

variable "tags" {
description = "Etiquetas generales"
type        = map(string)
default     = {}
}