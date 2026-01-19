output "vpc_id" {
description = "ID de la red creada"
value       = aws_vpc.this.id
}

output "public_subnet_ids" {
description = "Lista de IDs de las subnets públicas"

value = [for s in aws_subnet.public : s.id]
}