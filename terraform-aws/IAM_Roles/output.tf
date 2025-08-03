output "instance_profile_name" {
  description = "The name of the IAM instance profile for EC2 instances to access S3"
  value       = aws_iam_instance_profile.ec2_s3_upload_instance_profile.name
}