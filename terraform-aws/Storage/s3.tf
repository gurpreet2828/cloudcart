
# This Terraform configuration sets up an AWS S3 bucket with versioning enabled.
# This file is part of the Terraform AWS Storage module for setting up an S3 bucket with versioning enabled


# Create an S3 bucket for storing Kubernetes-related data
resource "aws_s3_bucket" "k8s_bucket" {
  count = var.enable_s3 ? 1 : 0 # Create the bucket only if enable_s3 is true
  bucket        = "my-k8s-bucket-1111"  # Name of the S3 bucket
  force_destroy = true
  tags = {
    Name        = "k8s-bucket"    # Tag for the bucket name
    Project     = "cloudcart"     # Tag for the project name
    Terraform   = "true"          # Tag to indicate the resource is managed by Terraform
    CreatedBy   = "Terraform"     # Tag to indicate the resource was created by Terraform
    Environment = var.environment # Use the environment variable for 
  }
  #lifecycle {
  # prevent_destroy = true
}


# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "k8s_bucket_versioning" {
  count = var.enable_s3 ? 1 : 0 # Create the versioning configuration only if enable_s3 is true
  bucket = aws_s3_bucket.k8s_bucket[count.index].id # Reference the S3 bucket created above
  # Enable versioning for the S3 bucket
  versioning_configuration {
    status = "Enabled"
  }

}

# Enable server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "k8s_bucket_encryption" {
  count = var.enable_s3 ? 1 : 0 # Create the encryption configuration only if enable_s3 is true
  bucket = aws_s3_bucket.k8s_bucket[count.index].id # Reference the S3 bucket created above

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Use AES256 encryption
    }
  }
}
# Enable logging for the S3 bucket
resource "aws_s3_bucket_logging" "k8s_bucket_logging" {
  count         = var.enable_s3 ? 1 : 0 # Create the logging configuration
  bucket        = aws_s3_bucket.k8s_bucket[count.index].id # Reference the S3 bucket created above
  target_bucket = aws_s3_bucket.k8s_bucket[count.index].id # Log to the same bucket (or specify another bucket)
  target_prefix = "logs/"                        # Prefix for the log files
}

# public access block for the S3 bucket
resource "aws_s3_bucket_public_access_block" "k8s_bucket_public_access_block" {
  count = var.enable_s3 ? 1 : 0 # Create the public access block configuration only if enable_s3 is true
  bucket                  = aws_s3_bucket.k8s_bucket[count.index].id # Reference the S3 bucket created above
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}
