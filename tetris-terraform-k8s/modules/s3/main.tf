resource "aws_s3_bucket" "main" {
bucket = "${var.prefix}-${var.bucket_name}"

tags = var.tags
}

resource "aws_s3_bucket_versioning" "main" {
bucket = aws_s3_bucket.main.id

versioning_configuration {
  status = var.bucket_versioning ? "Enabled" : "Suspended"
}
}

# Configuración de Propiedad (Necesario para usar ACLs hoy en día)
resource "aws_s3_bucket_ownership_controls" "main" {
bucket = aws_s3_bucket.main.id
rule {
  object_ownership = "BucketOwnerPreferred"
}
}

# Configuración de ACL (Permisos básicos)
resource "aws_s3_bucket_acl" "main" {
depends_on = [aws_s3_bucket_ownership_controls.main]

bucket = aws_s3_bucket.main.id
acl    = var.bucket_acl
}