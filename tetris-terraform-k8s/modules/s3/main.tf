resource "aws_s3_bucket" "this" {
bucket = "${var.prefix}-${var.bucket_name}"

tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
bucket = aws_s3_bucket.this.id

versioning_configuration {
  status = var.bucket_versioning ? "Enabled" : "Suspended"
}
}

# Configuración de Propiedad (Necesario para usar ACLs hoy en día)
resource "aws_s3_bucket_ownership_controls" "this" {
bucket = aws_s3_bucket.this.id
rule {
  object_ownership = "BucketOwnerPreferred"
}
}

# Configuración de ACL (Permisos básicos)
resource "aws_s3_bucket_acl" "this" {
depends_on = [aws_s3_bucket_ownership_controls.this]

bucket = aws_s3_bucket.this.id
acl    = var.bucket_acl
}