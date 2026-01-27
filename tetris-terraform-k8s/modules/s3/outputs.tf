output "bucket_id" {
description = "El nombre del bucket creado"
value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
description = "El ARN (identificador único) del bucket"
value       = aws_s3_bucket.main.arn
}