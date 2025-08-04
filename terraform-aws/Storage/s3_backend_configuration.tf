/*
resource "aws_s3_bucket" "k8s_backend_bucket" {
  bucket = "my-k8s-bucket-1111" # Name of the S3 bucket for backend configuration

  }
*/


/*
resource "aws_s3_bucket_lifecycle_configuration" "log_cleanup_rule" {
  bucket = aws_s3_bucket.k8s_backend_bucket.id

  rule 
    id     = "delete-cloudinit-logs"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    expiration {
      days = 7
    }  

  }
  }

resource "aws_s3_bucket_versioning" "k8s_backend_bucket_versioning" {
  bucket = aws_s3_bucket.k8s_backend_bucket.id

  versioning_configuration {
    status = "Enabled" # Enable versioning for the S3 bucket
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "k8s_backend_bucket_encryption" {
  bucket = aws_s3_bucket.k8s_backend_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Use AES256 encryption
    }
  }
}


resource "aws_s3_bucket_public_access_block" "k8s_backend_bucket_public_access_block" {
  bucket = aws_s3_bucket.k8s_backend_bucket.id # Reference the S3 bucket created above

  block_public_acls       = true # Block public ACLs
  ignore_public_acls      = true # Ignore public ACLs
  restrict_public_buckets = true # Restrict public buckets
  block_public_policy     = true # Block public policies
}

*/
