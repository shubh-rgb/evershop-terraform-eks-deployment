module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  name            = "eks-cluster-vpc"
  cidr            = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support  = true

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  map_public_ip_on_launch = true
  enable_nat_gateway = true

    # Disable default route table
  manage_default_route_table = false
}


# terraform tf state locking mechanism
data "aws_dynamodb_table" "terraform_lock_table" {
  name = "terraform-lock-table"
}

resource "aws_s3_bucket_policy" "terraform_state_policy" {
  bucket = "evershop-tfstate-bucket"  # Use the bucket name directly

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect    = "Allow"
        Resource  = "arn:aws:s3:::evershop-tfstate-bucket/*"
        Principal = "*"
      },
    ]
  })
}
resource "aws_iam_policy" "s3_full_access_policy" {
  name        = "S3FullAccessPolicy"
  description = "Provides full access to the evershop-tfstate-bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = [
          "arn:aws:s3:::evershop-tfstate-bucket",
          "arn:aws:s3:::evershop-tfstate-bucket/*"
        ]
      }
    ]
  })
}
resource "aws_iam_policy_attachment" "attach_s3_full_access" {
  name       = "attach-s3-full-access-policy"
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
  users      = ["shubhankar"]
}
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = "evershop-tfstate-bucket"  # Your bucket name

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}




# Remote backend configuration with S3 and DynamoDB for state locking
terraform {
  backend "s3" {
    bucket         = "evershop-tfstate-bucket"  # Replace with your bucket name
    key            = "global/s3/terraform.tfstate"    # Path within the bucket to store the state file
    region         = "ap-south-1"                    # AWS region where S3 bucket is located
    dynamodb_table = "terraform-lock-table"         # Name of DynamoDB table for state locking
    encrypt        = true                           # Encrypt state file at rest in S3
  }
}