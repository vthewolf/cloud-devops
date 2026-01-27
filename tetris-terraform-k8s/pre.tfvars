project     = "tetris"
environment = "pre"

# --- Red ---
vpc_cidr_block = "10.0.0.0/16"

public_subnet_params = {
"subnet1" = {
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
},
"subnet2" = {
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"
}
}

# --- EKS ---
eks_ng_instance_type = "t3.small"
eks_ng_desired_size  = 2
eks_ng_max_size      = 3
eks_ng_min_size      = 1
eks_engine_version   = "1.34"

# --- S3 ---
bucket_params = {
"state" = {
  bucket_versioning     = true
  bucket_lifecycle_rule = false
  bucket_acl            = "private"
}
}