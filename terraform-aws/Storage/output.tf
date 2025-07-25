output "domain_name" {
  value = var.enable_s3 ? aws_s3_bucket.k8s_bucket[0].bucket_domain_name : null
}

output "regional_domain_name" {
  value = var.enable_s3 ? aws_s3_bucket.k8s_bucket[0].bucket_regional_domain_name : null
}
