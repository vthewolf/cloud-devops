variable "prefix" {
description = "Prefijo para los nombres"
type        = string
}

variable "tags" {
description = "Etiquetas generales"
type        = map(string)
}

variable "vpc_cidr_block" {
description = "Rango IP de toda la red"
type        = string
}

variable "public_subnet_params" {
description = "Mapa de configuración de subnets públicas"
type        = map(any) 
}