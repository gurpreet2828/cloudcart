
# This Terraform configuration sets up an AWS S3 bucket with versioning enabled.
# This file is part of the Terraform AWS Storage module for setting up an S3 bucket with versioning enabled


# Create an S3 bucket for storing Kubernetes-related data
resource "aws_s3_bucket" "k8s_bucket" {
  bucket        = "my-k8s-bucket-1111" # Name of the S3 bucket
  force_destroy = true
  tags = {
    name        = "k8s-bucket"    # Tag for the bucket name
    Terraform   = "true"          # Tag to indicate the resource is managed by Terraform
    CreatedBy   = "Terraform"     # Tag to indicate the resource was created by Terraform
    Environment = var.environment # Use the environment variable for tagging
  }
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "k8s_bucket_versioning" {
  bucket = aws_s3_bucket.k8s_bucket.id # Reference the S3 bucket created above
  # Enable versioning for the S3 bucket
  versioning_configuration {
    status = "Enabled"
  }

}

# Enable server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "k8s_bucket_encryption" {
  bucket = aws_s3_bucket.k8s_bucket.id # Reference the S3 bucket created above

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Use AES256 encryption
    }
  }
}
# Enable logging for the S3 bucket
resource "aws_s3_bucket_logging" "k8s_bucket_logging" {
  bucket        = aws_s3_bucket.k8s_bucket.id # Reference the S3 bucket created above
  target_bucket = aws_s3_bucket.k8s_bucket.id # Log to the same bucket (or specify another bucket)
  target_prefix = "logs/"                     # Prefix for the log files
}

# public access block for the S3 bucket
resource "aws_s3_bucket_public_access_block" "k8s_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.k8s_bucket.id # Reference the S3 bucket created above
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true 

}
