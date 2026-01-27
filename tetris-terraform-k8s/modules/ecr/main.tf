resource "aws_ecr_repository" "main" {
name                 = "${var.prefix}-${var.name}"
image_tag_mutability = "MUTABLE" 

image_scanning_configuration {
  scan_on_push = true
}

force_delete = true # Permite destruir el repo aunque tenga imágenes dentro

tags = var.tags
}