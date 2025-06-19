
output "name" {
  value = aws_s3_bucket.k8s_bucket.id # Output the name of the S3 bucket
  
}

output "bucket_arn" {
  value = aws_s3_bucket.k8s_bucket.arn # Output the ARN of the S3 bucket
}

output "domain_name" {
  value = aws_s3_bucket.k8s_bucket.bucket_domain_name # Output the domain name of the S3 bucket
}

output "regional_domain_name" {
  value = aws_s3_bucket.k8s_bucket.bucket_regional_domain_name # Output the regional domain name of the S3 bucket
}