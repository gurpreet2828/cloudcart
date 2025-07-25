# S3 Storage Module
output "domain_name" {
  value = var.enable_s3 ? aws_s3_bucket.k8s_bucket[0].bucket_domain_name : null
}

output "regional_domain_name" {
  value = var.enable_s3 ? aws_s3_bucket.k8s_bucket[0].bucket_regional_domain_name : null
}

output "s3_storage_status" {
  description = "value indicating whether S3 storage is enabled or disabled"
  value = var.enable_s3 ? "ENABLED" : "DISABLED"
}

output "dynamodb_table_status" {
  description = "value indicating whether DynamoDB table is enabled or disabled"
  value = var.enable_dynamodb ? "ENABLED" : "DISABLED"
}

output "pvc_localstorage_status" {
  description = "value indicating whether PVC local storage provisioning is enabled or disabled"
  value = var.enable_pvc_localstorage ? "ENABLED" : "DISABLED"
}