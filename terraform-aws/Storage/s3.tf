
# This Terraform configuration sets up an AWS S3 bucket with versioning enabled.
# This file is part of the Terraform AWS Storage module for setting up an S3 bucket with versioning enabled



# The bucket name is dynamically generated using the AWS account ID to ensure uniqueness
resource "aws_s3_bucket" "k8s_bucket" {
  count         = var.enable_s3 ? 1 : 0                                             # Create the bucket only if enable_s3 is true
  bucket        = "cloudcart-bucket-${data.aws_caller_identity.current.account_id}" # Name of the S3 bucket
  force_destroy = true
  tags = {
    Name        = "cloudcart-bucket" # Tag for the bucket name
    Project     = "cloudcart"        # Tag for the project name
    Terraform   = "true"             # Tag to indicate the resource is managed by Terraform
    CreatedBy   = "Terraform"        # Tag to indicate the resource was created by Terraform
    Environment = var.environment    # Use the environment variable for 
  }
  #lifecycle {
  # prevent_destroy = true
}


# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "k8s_bucket_versioning" {
  count  = var.enable_s3 ? 1 : 0                    # Create the versioning configuration only if enable_s3 is true
  bucket = aws_s3_bucket.k8s_bucket[count.index].id # Reference the S3 bucket created above
  # Enable versioning for the S3 bucket
  versioning_configuration {
    status = "Enabled"
  }

}

# Enable server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "k8s_bucket_encryption" {
  count  = var.enable_s3 ? 1 : 0                    # Create the encryption configuration only if enable_s3 is true
  bucket = aws_s3_bucket.k8s_bucket[count.index].id # Reference the S3 bucket created above

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Use AES256 encryption
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "k8s_bucket_lifecycle" {
  count  = var.enable_s3 ? 1 : 0                    # Create the lifecycle configuration only if enable_s3 is true
  bucket = aws_s3_bucket.k8s_bucket[count.index].id # Reference the S3 bucket created above

  rule {
    id     = "delete-logs-after-7-days" # Unique identifier for the lifecycle rule
    status = "Enabled"

    filter {
      prefix = "logs/" # Apply this rule to objects with this prefix
    }
    expiration {
      days = 7 # Delete objects after 7 days
    }
  }

}

# public access block for the S3 bucket
resource "aws_s3_bucket_public_access_block" "k8s_bucket_public_access_block" {
  count                   = var.enable_s3 ? 1 : 0                    # Create the public access block configuration only if enable_s3 is true
  bucket                  = aws_s3_bucket.k8s_bucket[count.index].id # Reference the S3 bucket created above
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

/*
# Bucket policy to allow public read access to objects in the S3 bucket
resource "aws_s3_bucket_policy" "allow_public_access" {
  count = var.enable_s3 ? 1 : 0
  bucket = aws_s3_bucket.k8s_bucket[count.index].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.k8s_bucket[count.index].arn}/*"
      }
    ]
  })
}
*/