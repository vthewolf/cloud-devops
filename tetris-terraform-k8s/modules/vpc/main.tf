# 1. La Red Principal (VPC)
resource "aws_vpc" "main" {
cidr_block           = var.vpc_cidr_block
enable_dns_support   = true 
enable_dns_hostnames = true 

tags = merge(var.tags, {
  Name = "${var.prefix}-vpc"
})
}

# 2. La Puerta a Internet (Internet Gateway)
resource "aws_internet_gateway" "main" {
vpc_id = aws_vpc.main.id # Correcto: Referencia a .main

tags = merge(var.tags, {
  Name = "${var.prefix}-igw"
})
}

# 3. Las Subnets (Iterando sobre public_subnet_params)
resource "aws_subnet" "public" {
for_each = var.public_subnet_params # Correcto: Variable actualizada

vpc_id                  = aws_vpc.main.id
cidr_block              = each.value.cidr_block
availability_zone       = each.value.availability_zone
map_public_ip_on_launch = true 

tags = merge(var.tags, {
  Name = "${var.prefix}-${each.key}"
  "kubernetes.io/role/elb" = "1" 
})
}

# 4. Tabla de Rutas (El GPS)
resource "aws_route_table" "public" {
vpc_id = aws_vpc.main.id # Correcto: Referencia a .main

route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id # Correcto: Referencia a .main
}

tags = merge(var.tags, {
  Name = "${var.prefix}-public-rt"
})
}

# 5. Asociación
resource "aws_route_table_association" "public" {
for_each = aws_subnet.public 

subnet_id      = each.value.id
route_table_id = aws_route_table.public.id
}