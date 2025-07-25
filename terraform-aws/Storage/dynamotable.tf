resource "aws_dynamodb_table" "tfstate_lock" {
  count        = var.enable_dynamodb ? 1 : 0 # Create the table only if enable_dynamodb is true
  name         = "tfstate-lock-table" # Name of the DynamoDB table for state locking
  billing_mode = "PAY_PER_REQUEST"     # Use on-demand billing mode
  hash_key     = "LockID"              # Primary key for the table

  attribute {
    name = "LockID"                   # Primary key for the table
    type = "S"                        # String type
  }

  tags = {
    Name      = "tfstate-lock-table"  # Tag for the table name
    CreatedBy = "Terraform"            # Tag to indicate the resource was created by Terraform
  } 
  
}