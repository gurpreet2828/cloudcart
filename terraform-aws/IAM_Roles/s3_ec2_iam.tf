# Terraform configuration for creating an IAM role for EC2 instances to upload files to S3
# This role allows EC2 instances to have full access to the specified S3 bucket

resource "aws_iam_role" "ec2_s3_upload_role" {
  name = "EC2S3UploadRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

tags = {
    Name        = "EC2S3UploadRole" # Tag for the role name
    Project     = "cloudcart"      # Tag for the project name
    Terraform   = "true"           # Tag to indicate the resource is managed by Terraform
    CreatedBy   = "Terraform"      # Tag to indicate the resource was created by Terraform
    owner       = "Gurpreet"          # Tag for the owner of the resource
}
}
# Attach the AmazonS3FullAccess policy to the role
resource "aws_iam_role_policy_attachment" "s3_full_access_attach" {
  role       = aws_iam_role.ec2_s3_upload_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attach a custom policy to allow specific S3 actions
resource "aws_iam_role_policy" "ec2_s3_upload_policy" {
  name = "EC2S3UploadPolicy"
  role = aws_iam_role.ec2_s3_upload_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      Resource = [
        "arn:aws:s3:::my-k8s-bucket-1111",
        "arn:aws:s3:::my-k8s-bucket-1111/*"
      ]
    }]
  })
}

# create an instance profile for the role
resource "aws_iam_instance_profile" "ec2_s3_upload_instance_profile" {
    name = "EC2S3UploadInstanceProfile"
    role = aws_iam_role.ec2_s3_upload_role.id
}