variable "prefix" {
description = "Prefijo para los nombres"
type        = string
}

variable "vpc_cidr_block" {
description = "Rango IP de toda la red (ej: 10.0.0.0/16)"
type        = string
default     = "10.0.0.0/16"
}

# Kubernetes necesita AL MENOS 2 zonas de disponibilidad para funcionar bien en AWS (EKS).
variable "public_subnets" {
description = "Mapa de subnets públicas (Nombre -> Configuración)"
type = map(object({
  cidr_block        = string
  availability_zone = string
}))

default = {
  "subnet-a" = {
    cidr_block        = "10.0.1.0/24"
    availability_zone = "eu-north-1a"
  },
  "subnet-b" = {
    cidr_block        = "10.0.2.0/24"
    availability_zone = "eu-north-1b"
  }
}
}

variable "tags" {
description = "Etiquetas generales"
type        = map(string)
default     = {}
}