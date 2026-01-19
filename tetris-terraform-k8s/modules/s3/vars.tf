variable "prefix" {
description = "Prefijo para convención de nombres (ej: proyecto-entorno)"
type        = string
}

variable "bucket_name" {
description = "Sufijo para el nombre del bucket"
type        = string
}

variable "tags" {
description = "Mapa de etiquetas"
type        = map(string)
default     = {}
}

variable "bucket_acl" {
description = "ACL del bucket (private, public-read, etc)"
type        = string
default     = "private"
}

variable "bucket_versioning" {
description = "Activar versionado (true/false)"
type        = bool
default     = false
}

variable "bucket_lifecycle_rule" {
description = "Activar reglas de ciclo de vida por defecto"
type        = bool
default     = false
}