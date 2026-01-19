variable "prefix" {
description = "Prefijo para convención de nombres"
type        = string
}

variable "name" {
description = "Nombre del repositorio (ej: tetris-app)"
type        = string
}

variable "tags" {
description = "Etiquetas"
type        = map(string)
default     = {}
}