output "repository_url" {
description = "La URL donde debemos subir nuestra imagen Docker"
value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
value = aws_ecr_repository.this.arn
}