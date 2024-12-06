module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  name            = "eks-cluster-vpc"
  cidr            = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support  = true

  azs             = ["ap-south-1a","ap-south-1b"]
  private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
  public_subnets  = ["10.0.11.0/24","10.0.12.0/24"]
<<<<<<< HEAD
  map_public_ip_on_launch = true
=======

>>>>>>> 5e5e6c6d2a126d682af4464dc9ccb3d7e14ab179
  enable_nat_gateway = true
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
<<<<<<< HEAD
        Action    = [
          "s3:GetObject",
          "s3:PutObject"
        ]
=======
        Action    = "s3:GetObject"
>>>>>>> 5e5e6c6d2a126d682af4464dc9ccb3d7e14ab179
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