variable "prefix" {
description = "Prefijo para convención de nombres (ej: tetris-pre)"
type        = string
}

variable "tags" {
description = "Mapa de etiquetas globales"
type        = map(string)
}

variable "bucket_name" {
description = "Nombre único (clave) del bucket"
type        = string
}

variable "bucket_acl" {
description = "ACL del bucket (private, public-read, etc)"
type        = string
}

variable "bucket_versioning" {
description = "Activar versionado (true/false)"
type        = bool
}

variable "bucket_lifecycle_rule" {
description = "Activar reglas de ciclo de vida"
type        = bool
}