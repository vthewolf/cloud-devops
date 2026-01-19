resource "aws_ecr_repository" "this" {
# El nombre final será algo como "tetris-dev-app"
name                 = "${var.prefix}-${var.name}"
image_tag_mutability = "MUTABLE" # Permite sobreescribir la etiqueta "latest"

# ¡Truco pro! Escanea la imagen buscando virus al subirla (gratis y seguro)
image_scanning_configuration {
  scan_on_push = true
}

force_delete = true # Permite destruir el repo aunque tenga imágenes dentro

tags = var.tags
}