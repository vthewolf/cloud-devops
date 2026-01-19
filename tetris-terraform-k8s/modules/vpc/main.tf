# 1. La Red Principal (VPC)
resource "aws_vpc" "this" {
cidr_block           = var.vpc_cidr_block
enable_dns_support   = true # Necesario para que EKS encuentre servicios
enable_dns_hostnames = true # Necesario para que los nodos tengan nombre

tags = merge(var.tags, {
  Name = "${var.prefix}-vpc"
})
}

# 2. La Puerta a Internet (Internet Gateway)
# Sin esto, tu red está aislada del mundo (y es gratis, a diferencia del NAT Gateway)
resource "aws_internet_gateway" "this" {
vpc_id = aws_vpc.this.id

tags = merge(var.tags, {
  Name = "${var.prefix}-igw"
})
}

# 3. Las Subnets (Usamos un bucle 'for_each' para crear las que hayas definido)
resource "aws_subnet" "public" {
for_each = var.public_subnets

vpc_id                  = aws_vpc.this.id
cidr_block              = each.value.cidr_block
availability_zone       = each.value.availability_zone

# Importante: Asigna IP pública automática a lo que pongas aquí (ahorra costes de Elastic IPs)
map_public_ip_on_launch = true 

tags = merge(var.tags, {
  Name = "${var.prefix}-${each.key}"
  # Etiqueta OBLIGATORIA para que Kubernetes sepa dónde poner balanceadores públicos
  "kubernetes.io/role/elb" = "1" 
})
}

# 4. Tabla de Rutas (El GPS)
resource "aws_route_table" "public" {
vpc_id = aws_vpc.this.id

# Regla: Todo el tráfico (0.0.0.0/0) que vaya a Internet, envíalo al Gateway
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.this.id
}

tags = merge(var.tags, {
  Name = "${var.prefix}-public-rt"
})
}

# 5. Asociación (Conectar el GPS a los barrios)
resource "aws_route_table_association" "public" {
for_each = aws_subnet.public # Para cada subnet que creamos antes...

subnet_id      = each.value.id
route_table_id = aws_route_table.public.id
}